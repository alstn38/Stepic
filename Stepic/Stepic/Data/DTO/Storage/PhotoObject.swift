//
//  PhotoObject.swift
//  Stepic
//
//  Created by 강민수 on 4/4/25.
//

import Foundation

import RealmSwift

final class PhotoObject: EmbeddedObject {
    
    @Persisted var imagePath: String
    @Persisted var latitude: Double?
    @Persisted var longitude: Double?
    
    convenience init(
        imagePath: String,
        latitude: Double?,
        longitude: Double?
    ) {
        self.init()
        self.imagePath = imagePath
        self.latitude = latitude
        self.longitude = longitude
    }
}
