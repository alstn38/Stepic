//
//  LocationService.swift
//  Stepic
//
//  Created by 강민수 on 4/1/25.
//

import Foundation

import CoreLocation
import RxSwift

protocol LocationService {
    var currentLocation: Observable<CLLocation> { get }
    
    func getCurrentLocation() async throws -> CLLocation
    func startUpdatingLocation()
    func stopUpdatingLocation()
}

final class DefaultLocationService: NSObject, LocationService {
    
    private let locationManager = CLLocationManager()
    private let currentLocationSubject = BehaviorSubject<CLLocation?>(value: nil)
    
    var currentLocation: Observable<CLLocation> {
        return currentLocationSubject
            .compactMap { $0 }
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getCurrentLocation() async throws -> CLLocation {
        startUpdatingLocation()
        defer { stopUpdatingLocation() }
        return try await currentLocation
            .take(1)
            .asSingle()
            .value
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}

// MARK: - CLLocationManagerDelegate
extension DefaultLocationService: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }
        currentLocationSubject.onNext(latest)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update failed: \(error.localizedDescription)")
    }
}
