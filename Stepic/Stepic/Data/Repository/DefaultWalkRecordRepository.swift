//
//  DefaultWalkRecordRepository.swift
//  Stepic
//
//  Created by 강민수 on 4/4/25.
//

import UIKit

final class DefaultWalkRecordRepository: WalkRecordRepository {
    
    private let storageService: WalkRecordStorageService
    private let fileStorageService: ImageFileStorageService

    init(
        storageService: WalkRecordStorageService = DIContainer.shared.resolve(WalkRecordStorageService.self),
        fileStorageService: ImageFileStorageService = DIContainer.shared.resolve(ImageFileStorageService.self)
    ) {
        self.storageService = storageService
        self.fileStorageService = fileStorageService
    }

    func save(
        walkTrackingEntity: WalkTrackingEntity,
        weather: WeatherLocationEntity,
        photos: [WalkPhotoEntity],
        emotion: Int,
        title: String,
        content: String?,
        isBookmarked: Bool,
        thumbnailImage: UIImage
    ) throws {
        let id = UUID().uuidString

        let thumbnailPath = try fileStorageService.saveImage(thumbnailImage, fileName: "\(id)_thumbnail")

        let photoObjects = try photos.enumerated().map { index, photo in
            let path = try fileStorageService.saveImage(photo.image, fileName: "\(id)_photo_\(index)")
            return PhotoObject(
                imagePath: path,
                latitude: photo.location?.coordinate.latitude,
                longitude: photo.location?.coordinate.longitude
            )
        }

        let pathCoordinates = walkTrackingEntity.pathCoordinates.map {
            CoordinateObject(latitude: $0.latitude, longitude: $0.longitude)
        }

        let startLocation = LocationObject(from: walkTrackingEntity.startLocation)
        let endLocation = LocationObject(from: walkTrackingEntity.endLocation)

        let record = WalkRecordObject(
            id: id,
            isBookmarked: isBookmarked,
            weatherSymbol: weather.symbolName,
            weatherDescription: weather.description,
            temperature: weather.temperature,
            startTime: walkTrackingEntity.startTime,
            endTime: walkTrackingEntity.endTime,
            startLocation: startLocation,
            endLocation: endLocation,
            duration: walkTrackingEntity.duration,
            distance: walkTrackingEntity.distance,
            startDate: walkTrackingEntity.startDate,
            pathCoordinates: pathCoordinates,
            photos: photoObjects,
            emotion: emotion,
            recordTitle: title,
            content: content,
            thumbnailImagePath: thumbnailPath
        )

        try storageService.save(record)
    }
}
