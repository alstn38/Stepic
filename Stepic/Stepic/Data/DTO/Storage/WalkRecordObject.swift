//
//  WalkRecordObject.swift
//  Stepic
//
//  Created by 강민수 on 4/4/25.
//

import Foundation

import RealmSwift

final class WalkRecordObject: Object {
    
    @Persisted(primaryKey: true) var id: String
    
    @Persisted var isBookmarked: Bool
    @Persisted var weatherSymbol: String
    @Persisted var weatherDescription: String
    @Persisted var temperature: String
    
    @Persisted var startTime: Date
    @Persisted var endTime: Date
    @Persisted var startLocation: LocationObject?
    @Persisted var endLocation: LocationObject?
    @Persisted var duration: Double
    @Persisted var distance: Double
    @Persisted var startDate: Date
    
    @Persisted var pathCoordinates: List<CoordinateObject>
    
    @Persisted var photos: List<PhotoObject>
    
    @Persisted var emotion: Int
    @Persisted var recordTitle: String
    @Persisted var content: String?
    
    @Persisted var thumbnailImagePath: String
    
    convenience init(
         id: String,
         isBookmarked: Bool,
         weatherSymbol: String,
         weatherDescription: String,
         temperature: String,
         startTime: Date,
         endTime: Date,
         startLocation: LocationObject,
         endLocation: LocationObject,
         duration: Double,
         distance: Double,
         startDate: Date,
         pathCoordinates: [CoordinateObject],
         photos: [PhotoObject],
         emotion: Int,
         recordTitle: String,
         content: String?,
         thumbnailImagePath: String
     ) {
         self.init()
         self.id = id
         self.isBookmarked = isBookmarked
         self.weatherSymbol = weatherSymbol
         self.weatherDescription = weatherDescription
         self.temperature = temperature
         self.startTime = startTime
         self.endTime = endTime
         self.startLocation = startLocation
         self.endLocation = endLocation
         self.duration = duration
         self.distance = distance
         self.startDate = startDate
         self.pathCoordinates.append(objectsIn: pathCoordinates)
         self.photos.append(objectsIn: photos)
         self.emotion = emotion
         self.recordTitle = recordTitle
         self.content = content
         self.thumbnailImagePath = thumbnailImagePath
     }
}
