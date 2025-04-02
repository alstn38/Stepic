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
    func reverseGeocode(location: CLLocation) async throws -> AddressDTO
}

final class DefaultGeocoderService: GeocoderService {
    
    private let geocoder = CLGeocoder()
    
    func reverseGeocode(location: CLLocation) async throws -> AddressDTO {
        return try await withCheckedThrowingContinuation { continuation in
            geocoder.reverseGeocodeLocation(location) { placeMarks, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let placeMark = placeMarks?.first {
                    let address = AddressDTO(
                        city: placeMark.locality ?? "Unknown",
                        district: placeMark.subLocality ?? "Unknown",
                        street: placeMark.thoroughfare ?? "Unknown"
                    )
                    continuation.resume(returning: address)
                } else {
                    continuation.resume(returning: AddressDTO.dummy())
                }
            }
        }
    }
}
