//
//  CoordinateObject.swift
//  Stepic
//
//  Created by 강민수 on 4/4/25.
//

import Foundation

import RealmSwift

final class CoordinateObject: EmbeddedObject {
    
    @Persisted var latitude: Double
    @Persisted var longitude: Double
    
    convenience init(
        latitude: Double,
        longitude: Double
    ) {
        self.init()
        self.latitude = latitude
        self.longitude = longitude
    }
}
