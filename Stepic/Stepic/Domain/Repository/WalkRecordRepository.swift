//
//  WalkRecordRepository.swift
//  Stepic
//
//  Created by 강민수 on 4/4/25.
//

import UIKit

protocol WalkRecordRepository {
    func save(
        walkTrackingEntity: WalkTrackingEntity,
        weather: WeatherLocationEntity,
        photos: [WalkPhotoEntity],
        emotion: Int,
        title: String,
        content: String?,
        isBookmarked: Bool,
        thumbnailImage: UIImage
    ) throws
}
