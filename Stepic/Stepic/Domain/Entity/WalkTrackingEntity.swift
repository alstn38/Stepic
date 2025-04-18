//
//  WalkTrackingEntity.swift
//  Stepic
//
//  Created by 강민수 on 4/2/25.
//

import Foundation

import CoreLocation

struct WalkTrackingEntity {
    let startTime: Date
    let endTime: Date
    let startLocation: LocationEntity
    let endLocation: LocationEntity
    let duration: TimeInterval
    let distance: Double
    let pathCoordinates: [CLLocationCoordinate2D]
    let startDate: Date
}

extension WalkTrackingEntity {
    
    static func dummy() -> WalkTrackingEntity {
        return WalkTrackingEntity(
            startTime: Date(),
            endTime: Date(),
            startLocation: .dummy(),
            endLocation: .dummy(),
            duration: 0,
            distance: 0,
            pathCoordinates: [],
            startDate: Date()
        )
    }
}
