//
//  LocationEntity.swift
//  Stepic
//
//  Created by 강민수 on 4/3/25.
//

import Foundation

struct LocationEntity {
    let city: String
    let district: String
    let street: String
}

extension LocationEntity {
    
    static func dummy() -> LocationEntity {
        return LocationEntity(
            city: "",
            district: "",
            street: ""
        )
    }
}
