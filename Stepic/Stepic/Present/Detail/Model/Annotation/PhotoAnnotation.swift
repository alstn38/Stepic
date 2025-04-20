//
//  PhotoAnnotation.swift
//  Stepic
//
//  Created by 강민수 on 4/3/25.
//

import MapKit

final class PhotoAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    let photo: WalkPhotoEntity
    
    init(photo: WalkPhotoEntity) {
        self.photo = photo
        
        if let location = photo.location {
            self.coordinate = location.coordinate
        } else {
            self.coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
        
        super.init()
    }
}
