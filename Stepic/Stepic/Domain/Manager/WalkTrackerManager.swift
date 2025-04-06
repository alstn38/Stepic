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
            .subscribe(onNext: { [weak self] location in
                guard let self = self else { return }

                self.pathCoordinates.append(location.coordinate)

                if let prev = self.previousLocation {
                    let addedDistance = location.distance(from: prev)
                    self.totalDistanceRelay.accept(self.totalDistanceRelay.value + addedDistance)
                }

                self.previousLocation = location
            })
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
