//
//  LocationObject.swift
//  Stepic
//
//  Created by 강민수 on 4/4/25.
//

import Foundation

import RealmSwift

final class LocationObject: EmbeddedObject {
    
    @Persisted var city: String
    @Persisted var district: String
    @Persisted var street: String
    
    convenience init(from entity: LocationEntity) {
        self.init()
        self.city = entity.city
        self.district = entity.district
        self.street = entity.street
    }
}
