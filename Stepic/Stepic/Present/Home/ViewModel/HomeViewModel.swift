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
        let viewWillAppear: Observable<Void>
        let selectDateDidChange: Observable<YearMonth>
        let calendarDidSelect: Observable<Date>
        let recordButtonDidTap: Observable<Void>
    }
    
    struct Output {
        let weatherLocationData: Driver<WeatherLocationEntity>
        let selectedDate: Driver<YearMonth>
        let walkDiaryData: Driver<[WalkDiaryEntity]>
        let selectDiaryData: Driver<[WalkDiaryEntity]>
        let moveToWalkView: Driver<Void>
        let presentAlert: Driver<AlertType>
    }
    
    private let walkRecordRepository: WalkRecordRepository
    private let locationPermissionManager: LocationPermissionManager
    private let weatherLocationRepository: WeatherLocationRepository
    private let disposeBag = DisposeBag()
    
    init(
        walkRecordRepository: WalkRecordRepository = DIContainer.shared.resolve(WalkRecordRepository.self),
        locationPermissionManager: LocationPermissionManager = DIContainer.shared.resolve(LocationPermissionManager.self),
        weatherLocationRepository: WeatherLocationRepository = DIContainer.shared.resolve(WeatherLocationRepository.self)
    ) {
        self.walkRecordRepository = walkRecordRepository
        self.locationPermissionManager = locationPermissionManager
        self.weatherLocationRepository = weatherLocationRepository
    }
    
    func transform(from input: Input) -> Output {
        let weatherLocationDataRelay = BehaviorRelay(value: WeatherLocationEntity.loadingDummy())
        let selectedDateRelay = BehaviorRelay<YearMonth>(value: getTodayDate())
        let walkDiaryDataRelay = BehaviorRelay<[WalkDiaryEntity]>(value: [])
        let selectDiaryDataRelay = BehaviorRelay<[WalkDiaryEntity]>(value: [])
        let moveToWalkViewRelay = PublishRelay<Void>()
        let presentAlertRelay = PublishRelay<AlertType>()
        
        let weatherLocationUpdateRelay = PublishRelay<Void>()
        
        input.viewWillAppear
            .withLatestFrom(selectedDateRelay)
            .bind(with: self) { owner, yearMonth in
                let walkDiaryData = owner.walkRecordRepository.fetch(byYear: yearMonth.year, month: yearMonth.month)
                walkDiaryDataRelay.accept(walkDiaryData)
                
                let calendar = Calendar.current
                let filtered = walkDiaryDataRelay.value
                    .filter { calendar.isDate($0.startDate, inSameDayAs: Date()) }
                selectDiaryDataRelay.accept(filtered)
            }
            .disposed(by: disposeBag)
        
        input.selectDateDidChange
            .bind(with: self) { owner, yearMonth in
                selectedDateRelay.accept(yearMonth)
                
                let walkDiaryData = owner.walkRecordRepository.fetch(byYear: yearMonth.year, month: yearMonth.month)
                walkDiaryDataRelay.accept(walkDiaryData)
                
                let calendar = Calendar.current
                let filtered = walkDiaryDataRelay.value
                    .filter { calendar.isDate($0.startDate, inSameDayAs: Date()) }
                selectDiaryDataRelay.accept(filtered)
            }
            .disposed(by: disposeBag)
        
        input.calendarDidSelect
            .bind(with: self) { owner, selectDate in
                let calendar = Calendar.current
                let filtered = walkDiaryDataRelay.value
                    .filter { calendar.isDate($0.startDate, inSameDayAs: selectDate) }
                selectDiaryDataRelay.accept(filtered)
            }
            .disposed(by: disposeBag)
        
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
            selectedDate: selectedDateRelay.asDriver(),
            walkDiaryData: walkDiaryDataRelay.asDriver(),
            selectDiaryData: selectDiaryDataRelay.asDriver(),
            moveToWalkView: moveToWalkViewRelay.asDriver(onErrorJustReturn: ()),
            presentAlert: presentAlertRelay.asDriver(onErrorJustReturn: .locationSetting)
        )
    }
    
    private func getTodayDate() -> YearMonth {
        let today = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: today)
        let month = calendar.component(.month, from: today)
        return YearMonth(year: year, month: month)
    }
}

extension HomeViewModel {
    
    enum AlertType {
        case messageError(title: String, message: String)
        case locationSetting
    }
}
