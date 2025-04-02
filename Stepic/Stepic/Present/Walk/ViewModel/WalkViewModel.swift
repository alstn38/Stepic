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
    }
    
    struct Output {
        let weatherLocationData: Driver<WeatherLocationEntity>
        let timer: Driver<String>
        let distance: Driver<String>
        let presentAlert: Driver<AlertType>
    }
    
    private let locationPermissionManager: LocationPermissionManager
    private let weatherLocationRepository: WeatherLocationRepository
    private let walkTrackerManager: WalkTrackerManager
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
            presentAlert: presentAlertRelay.asDriver(onErrorJustReturn: .messageError(title: "", message: ""))
        )
    }
}

extension WalkViewModel {
    
    enum AlertType {
        case messageError(title: String, message: String)
        case locationSetting
    }
}

