//
//  WalkDiaryEntity.swift
//  Stepic
//
//  Created by 강민수 on 4/4/25.
//

import CoreLocation
import UIKit

struct WalkDiaryEntity: Identifiable {
    let id: String
    let isBookmarked: Bool

    let weatherSymbol: String
    let weatherDescription: String
    let temperature: String

    let startTime: Date
    let endTime: Date
    let startLocation: LocationEntity
    let endLocation: LocationEntity
    let duration: TimeInterval
    let distance: Double
    let startDate: Date

    let pathCoordinates: [CLLocationCoordinate2D]

    let photos: [WalkPhotoEntity]

    let emotion: Int
    let recordTitle: String
    let content: String?

    let thumbnailImage: UIImage
}

extension WalkDiaryEntity {
    
    func changeBookMark(_ isBookmark: Bool) -> WalkDiaryEntity {
        return WalkDiaryEntity(
            id: id,
            isBookmarked: isBookmark,
            weatherSymbol: weatherSymbol,
            weatherDescription: weatherDescription,
            temperature: temperature,
            startTime: startTime,
            endTime: endTime,
            startLocation: startLocation,
            endLocation: endLocation,
            duration: duration,
            distance: distance,
            startDate: startDate,
            pathCoordinates: pathCoordinates,
            photos: photos,
            emotion: emotion,
            recordTitle: recordTitle,
            content: content,
            thumbnailImage: thumbnailImage
        )
    }
}
