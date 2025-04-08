//
//  GeocoderService.swift
//  Stepic
//
//  Created by 강민수 on 4/2/25.
//

import Foundation

import CoreLocation
import RxSwift

protocol GeocoderService {
    func reverseGeocode(location: CLLocation) async throws -> LocationEntity
}

final class DefaultGeocoderService: GeocoderService {
    
    func reverseGeocode(location: CLLocation) async throws -> LocationEntity {
        let geocoder = CLGeocoder()
        
        return try await withCheckedThrowingContinuation { continuation in
            geocoder.reverseGeocodeLocation(location) { placeMarks, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let placeMark = placeMarks?.first {
                    let address = LocationEntity(
                        city: placeMark.locality ?? "",
                        district: placeMark.subLocality ?? "",
                        street: placeMark.thoroughfare ?? ""
                    )
                    continuation.resume(returning: address)
                } else {
                    continuation.resume(returning: LocationEntity.dummy())
                }
            }
        }
    }
}
