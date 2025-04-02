//
//  HomeViewModel.swift
//  Stepic
//
//  Created by 강민수 on 4/1/25.
//

import Foundation

import CoreLocation
import RxCocoa
import RxSwift

final class HomeViewModel: InputOutputModel {
    
    struct Input {
        let recordButtonDidTap: Observable<Void>
    }
    
    struct Output {
        let weatherLocationData: Driver<WeatherLocationEntity>
        let moveToWalkView: Driver<Void>
        let presentAlert: Driver<AlertType>
    }
    
    private let locationPermissionManager: LocationPermissionManager
    private let weatherLocationRepository: WeatherLocationRepository
    private let disposeBag = DisposeBag()
    
    init(
        locationPermissionManager: LocationPermissionManager = DIContainer.shared.resolve(LocationPermissionManager.self),
        weatherLocationRepository: WeatherLocationRepository = DIContainer.shared.resolve(WeatherLocationRepository.self)
    ) {
        self.locationPermissionManager = locationPermissionManager
        self.weatherLocationRepository = weatherLocationRepository
    }
    
    func transform(from input: Input) -> Output {
        let weatherLocationDataRelay = BehaviorRelay(value: WeatherLocationEntity.loadingDummy())
        let moveToWalkViewRelay = PublishRelay<Void>()
        let presentAlertRelay = PublishRelay<AlertType>()
        
        let weatherLocationUpdateRelay = PublishRelay<Void>()
        
        input.recordButtonDidTap
            .bind(with: self) { owner, _ in
                if owner.locationPermissionManager.isAuthorized() {
                    moveToWalkViewRelay.accept(())
                } else {
                    presentAlertRelay.accept(AlertType.locationSetting)
                }
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
            moveToWalkView: moveToWalkViewRelay.asDriver(onErrorJustReturn: ()),
            presentAlert: presentAlertRelay.asDriver(onErrorJustReturn: .locationSetting)
        )
    }
}

extension HomeViewModel {
    
    enum AlertType {
        case messageError(title: String, message: String)
        case locationSetting
    }
}
