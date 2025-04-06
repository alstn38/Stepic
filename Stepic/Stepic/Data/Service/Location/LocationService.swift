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
    func getCurrentTrackingLocation() async throws -> CLLocation
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
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// 위치를 한번만 요청하고 위치 연결을 해제하는 메서드
    func getCurrentLocation() async throws -> CLLocation {
        startUpdatingLocation()
        defer { stopUpdatingLocation() }
        return try await currentLocation
            .take(1)
            .asSingle()
            .value
    }
    
    /// 이동중에 위치를 요청하는 메서드 위치 연결을 해제하지 않는다.
    func getCurrentTrackingLocation() async throws -> CLLocation {
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
