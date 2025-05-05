//
//  WalkTrackerManager.swift
//  Stepic
//
//  Created by 강민수 on 4/2/25.
//

import Foundation

import CoreLocation
import RxSwift
import RxCocoa

protocol WalkTrackerManager {
    var totalDistance: Observable<Double> { get }
    
    func startTracking()
    func stopTracking() async throws -> WalkTrackingEntity
    func resetTracking()
    func getCurrentTrackingLocation() async throws -> CLLocation
}

final class DefaultWalkTrackerManager: WalkTrackerManager {
    
    private let locationService: LocationService
    private let geocoderService: GeocoderService
    
    private var kalmanFilterLat: KalmanFilterManager?
    private var kalmanFilterLon: KalmanFilterManager?
    
    private var startTime: Date?
    private var endTime: Date?
    private var pathCoordinates: [CLLocationCoordinate2D] = []
    private var previousLocation: CLLocation?
    
    private let totalDistanceRelay = BehaviorRelay<Double>(value: 0)
    private var disposeBag = DisposeBag()
    
    var totalDistance: Observable<Double> {
        totalDistanceRelay.asObservable()
    }
    
    init(
        locationService: LocationService = DIContainer.shared.resolve(LocationService.self),
        geocoderService: GeocoderService = DIContainer.shared.resolve(GeocoderService.self)
    ) {
        self.locationService = locationService
        self.geocoderService = geocoderService
    }
    
    func startTracking() {
        startTime = Date()
        locationService.startUpdatingLocation()
        
        locationService.currentLocation
            .subscribe { [weak self] location in
                guard let self = self else { return }
                
                /// 첫 위치 측정 시 칼만 필터 초기화 (위도, 경도 각각)
                if self.kalmanFilterLat == nil || self.kalmanFilterLon == nil {
                    self.kalmanFilterLat = KalmanFilterManager(
                        initialValue: location.coordinate.latitude,
                        initialError: 1.0,
                        processNoise: 0.01,
                        measurementNoise: 0.1
                    )
                    self.kalmanFilterLon = KalmanFilterManager(
                        initialValue: location.coordinate.longitude,
                        initialError: 1.0,
                        processNoise: 0.01,
                        measurementNoise: 0.1
                    )
                }
                
                /// 측정값에 칼만 필터 적용하여 보정된 값 계산
                let accuracy = location.horizontalAccuracy
                let speed = location.speed

                let filteredLat = self.kalmanFilterLat?.update(
                    measurement: location.coordinate.latitude,
                    accuracy: accuracy,
                    speed: speed
                ) ?? location.coordinate.latitude

                let filteredLon = self.kalmanFilterLon?.update(
                    measurement: location.coordinate.longitude,
                    accuracy: accuracy,
                    speed: speed
                ) ?? location.coordinate.longitude
                
                /// 보정된 좌표를 사용하여 새로운 CLLocation 생성
                let filteredLocation = CLLocation(latitude: filteredLat, longitude: filteredLon)
                
                /// 경로 좌표 배열에 보정된 위치 추가
                self.pathCoordinates.append(filteredLocation.coordinate)
                
                /// 이전 위치와의 거리 계산하여 누적
                if let prev = self.previousLocation {
                    let addedDistance = filteredLocation.distance(from: prev)
                    self.totalDistanceRelay.accept(self.totalDistanceRelay.value + addedDistance)
                }
                
                /// 다음 업데이트를 위한 이전 위치 갱신
                self.previousLocation = filteredLocation
            }
            .disposed(by: disposeBag)
    }
    
    func stopTracking() async throws -> WalkTrackingEntity {
        defer { locationService.stopUpdatingLocation() }
        
        endTime = Date()
        
        let distance = totalDistanceRelay.value / 1000.0
        let duration = (endTime?.timeIntervalSince(startTime ?? Date())) ?? 0
        let date = Calendar.current.startOfDay(for: startTime ?? Date())
        
        let startCLLocation = CLLocation(latitude: pathCoordinates.first?.latitude ?? 0, longitude: pathCoordinates.first?.longitude ?? 0)
        let endCLLocation = CLLocation(latitude: pathCoordinates.last?.latitude ?? 0, longitude: pathCoordinates.last?.longitude ?? 0)
        async let startLocation = try geocoderService.reverseGeocode(location: startCLLocation)
        async let endLocation = try geocoderService.reverseGeocode(location: endCLLocation)
        let (start, end) = try await (startLocation, endLocation)
        
        return WalkTrackingEntity(
            startTime: startTime ?? Date(),
            endTime: endTime ?? Date(),
            startLocation: start,
            endLocation: end,
            duration: duration,
            distance: distance,
            pathCoordinates: pathCoordinates,
            startDate: date
        )
    }
    
    func resetTracking() {
        startTime = nil
        endTime = nil
        previousLocation = nil
        pathCoordinates = []
        totalDistanceRelay.accept(0)
        disposeBag = DisposeBag()
    }
    
    func getCurrentTrackingLocation() async throws -> CLLocation {
        return try await locationService.getCurrentTrackingLocation()
    }
}
