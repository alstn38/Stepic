//
//  WalkViewModel.swift
//  Stepic
//
//  Created by 강민수 on 4/2/25.
//

import Foundation

import RxSwift
import RxCocoa

final class WalkViewModel: InputOutputModel {
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let startTrigger: Observable<Void>
        let albumButtonDidTap: Observable<Void>
        let photoButtonDidTap: Observable<Void>
        let pauseButtonLongDidPress: Observable<Void>
        let didAddPhoto: Observable<[WalkPhotoEntity]>
        let deletePhoto: Observable<Int>
    }
    
    struct Output {
        let weatherLocationData: Driver<WeatherLocationEntity>
        let timer: Driver<String>
        let distance: Driver<String>
        let walkPhotoData: Driver<[WalkPhotoEntity]>
        let presentPickerView: Driver<ImagePickerSource>
        let moveToSummaryView: Driver<WalkResultEntity>
        let presentAlert: Driver<AlertType>
    }
    
    private let locationPermissionManager: LocationPermissionManager
    private let weatherLocationRepository: WeatherLocationRepository
    private let walkTrackerManager: WalkTrackerManager
    
    private let maxPhotoCount: Int = 10
    private let walkPhotoData = BehaviorRelay<[WalkPhotoEntity]>(value: [])
    private let disposeBag = DisposeBag()
    
    init(
        locationPermissionManager: LocationPermissionManager = DIContainer.shared.resolve(LocationPermissionManager.self),
        weatherLocationRepository: WeatherLocationRepository = DIContainer.shared.resolve(WeatherLocationRepository.self),
        walkTrackerManager: WalkTrackerManager = DIContainer.shared.resolve(WalkTrackerManager.self)
    ) {
        self.locationPermissionManager = locationPermissionManager
        self.weatherLocationRepository = weatherLocationRepository
        self.walkTrackerManager = walkTrackerManager
    }
    
    func transform(from input: Input) -> Output {
        let weatherLocationDataRelay = BehaviorRelay(value: WeatherLocationEntity.loadingDummy())
        let startTimeRelay = BehaviorRelay<Date?>(value: nil)
        let presentAlbumViewRelay = PublishRelay<ImagePickerSource>()
        let moveToSummaryViewRelay = PublishRelay<WalkResultEntity>()
        let presentAlertRelay = PublishRelay<AlertType>()
        
        let weatherLocationUpdateRelay = PublishRelay<Void>()
        
        input.viewDidLoad
            .bind(with: self) { owner, _ in
                owner.walkTrackerManager.resetTracking()
            }
            .disposed(by: disposeBag)
        
        input.startTrigger
            .bind(with: self) { owner, _ in
                owner.walkTrackerManager.startTracking()
                startTimeRelay.accept(Date())
            }
            .disposed(by: disposeBag)
        
        input.albumButtonDidTap
            .withUnretained(self)
            .map { $0.0.maxPhotoCount - $0.0.walkPhotoData.value.count }
            .bind { possibleCount in
                if possibleCount > 0 {
                    presentAlbumViewRelay.accept(.library(maxCount: possibleCount))
                } else {
                    presentAlertRelay.accept(.messageError(
                        title: .StringLiterals.Alert.photoLimitAlertTitle,
                        message: .StringLiterals.Alert.photoLimitAlertMessage
                    ))
                }
            }
            .disposed(by: disposeBag)
        
        input.photoButtonDidTap
            .withUnretained(self)
            .map { $0.0.maxPhotoCount - $0.0.walkPhotoData.value.count }
            .bind { possibleCount in
                if possibleCount > 0 {
                    presentAlbumViewRelay.accept(.camera(maxCount: possibleCount))
                } else {
                    presentAlertRelay.accept(.messageError(
                        title: .StringLiterals.Alert.photoLimitAlertTitle,
                        message: .StringLiterals.Alert.photoLimitAlertMessage
                    ))
                }
            }
            .disposed(by: disposeBag)
        
        input.pauseButtonLongDidPress
            .bind(with: self) { owner, _ in
                Task {
                    do {
                        let walkTrackingData = try await owner.walkTrackerManager.stopTracking()
                        let walkResult = WalkResultEntity(
                            photos: owner.walkPhotoData.value,
                            weather: weatherLocationDataRelay.value,
                            tracking: walkTrackingData
                        )
                        moveToSummaryViewRelay.accept(walkResult)
                    } catch {
                        presentAlertRelay.accept(.messageError(
                            title: "Error",
                            message: error.localizedDescription
                        ))
                    }
                }
            }
            .disposed(by: disposeBag)
        
        input.didAddPhoto
            .bind(with: self) { owner, inputPhotos in
                let newPhotoData = owner.walkPhotoData.value + inputPhotos
                owner.walkPhotoData.accept(newPhotoData)
            }
            .disposed(by: disposeBag)
        
        input.deletePhoto
            .bind(with: self) { owner, index in
                var newPhotoData = owner.walkPhotoData.value
                _ = newPhotoData.remove(at: index)
                owner.walkPhotoData.accept(newPhotoData)
            }
            .disposed(by: disposeBag)
        
        weatherLocationUpdateRelay
            .bind(with: self) { owner, _ in
                Task {
                    do {
                        let data = try await owner.weatherLocationRepository.fetchCurrentWeatherLocationInfo()
                        weatherLocationDataRelay.accept(data)
                    } catch {
                        presentAlertRelay.accept(.messageError(
                            title: "Error",
                            message: error.localizedDescription
                        ))
                    }
                }
            }
            .disposed(by: disposeBag)
        
        let elapsedTime = input.startTrigger
            .flatMapLatest { _ in
                Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
                    .startWith(0)
            }
            .withLatestFrom(startTimeRelay) { _, start -> String in
                guard let start = start else { return "00:00" }
                let elapsed = Int(Date().timeIntervalSince(start))
                if elapsed < 3600 {
                    return String(format: "%02d:%02d", elapsed / 60, elapsed % 60)
                } else {
                    return String(format: "%02d:%02d:%02d", elapsed / 3600, (elapsed % 3600) / 60, elapsed % 60)
                }
            }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "00:00")
        
        let distance = walkTrackerManager.totalDistance
            .map { String(format: "%.2f km", $0 / 1000.0) }
            .asDriver(onErrorJustReturn: "0.00 km")
        
        locationPermissionManager.authorizationStatus
            .bind(with: self) { owner, authorizationStatus in
                switch authorizationStatus {
                case .notDetermined:
                    owner.locationPermissionManager.requestAuthorization()
                case .denied:
                    presentAlertRelay.accept(AlertType.locationSetting)
                case .authorizedWhenInUse, .authorizedAlways:
                    weatherLocationUpdateRelay.accept(())
                default:
                    presentAlertRelay.accept(AlertType.messageError(
                        title: "Location Error",
                        message: "Unknown"
                    ))
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            weatherLocationData: weatherLocationDataRelay.asDriver(),
            timer: elapsedTime,
            distance: distance,
            walkPhotoData: walkPhotoData.asDriver(),
            presentPickerView: presentAlbumViewRelay.asDriver(onErrorDriveWith: .empty()),
            moveToSummaryView: moveToSummaryViewRelay.asDriver(onErrorDriveWith: .empty()),
            presentAlert: presentAlertRelay.asDriver(onErrorDriveWith: .empty())
        )
    }
}

extension WalkViewModel {
    
    enum AlertType {
        case messageError(title: String, message: String)
        case locationSetting
    }
    
    enum ImagePickerSource {
        case library(maxCount: Int)
        case camera(maxCount: Int)
    }
}
