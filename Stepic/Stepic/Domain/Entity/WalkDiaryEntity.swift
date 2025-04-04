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
    let duration: Double
    let distance: Double
    let startDate: Date

    let pathCoordinates: [CLLocationCoordinate2D]

    let photos: [WalkPhotoEntity]

    let emotion: Int
    let recordTitle: String
    let content: String?

    let thumbnailImage: UIImage
}
