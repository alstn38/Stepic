//
//  LocationPermissionManager.swift
//  Stepic
//
//  Created by 강민수 on 4/2/25.
//

import Foundation

import CoreLocation
import RxSwift

protocol LocationPermissionManager {
    var authorizationStatus: Observable<CLAuthorizationStatus> { get }
    
    func requestAuthorization()
    func currentAuthorizationStatus() -> CLAuthorizationStatus
    func isAuthorized() -> Bool
}

final class DefaultLocationPermissionManager: NSObject, LocationPermissionManager {
    
    private let locationManager = CLLocationManager()
    private lazy var statusSubject = BehaviorSubject<CLAuthorizationStatus>(
        value: self.locationManager.authorizationStatus
    )
    
    var authorizationStatus: Observable<CLAuthorizationStatus> {
        return statusSubject.asObservable()
    }

    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func currentAuthorizationStatus() -> CLAuthorizationStatus {
        return locationManager.authorizationStatus
    }

    func isAuthorized() -> Bool {
        let status = try? statusSubject.value()
        return status == .authorizedAlways || status == .authorizedWhenInUse
    }
}

extension DefaultLocationPermissionManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        statusSubject.onNext(status)
    }
}
