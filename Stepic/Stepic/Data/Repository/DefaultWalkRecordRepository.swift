//
//  DefaultWalkRecordRepository.swift
//  Stepic
//
//  Created by 강민수 on 4/4/25.
//

import UIKit
import CoreLocation
import WidgetKit

final class DefaultWalkRecordRepository: WalkRecordRepository {
    
    private let storageService: WalkRecordStorageService
    private let fileStorageService: ImageFileStorageService
    private let widgetCalendarService: WidgetCalendarWritableStorageService
    
    init(
        storageService: WalkRecordStorageService = DIContainer.shared.resolve(WalkRecordStorageService.self),
        fileStorageService: ImageFileStorageService = DIContainer.shared.resolve(ImageFileStorageService.self),
        widgetCalendarService: WidgetCalendarWritableStorageService = DIContainer.shared.resolve(WidgetCalendarWritableStorageService.self)
    ) {
        self.storageService = storageService
        self.fileStorageService = fileStorageService
        self.widgetCalendarService = widgetCalendarService
    }
    
    func save(entity: WalkDiaryEntity) throws {
        let id = entity.id
        let thumbnailPath = try fileStorageService.saveImage(entity.thumbnailImage, fileName: "\(id)_thumbnail")
        
        let photoObjects = try entity.photos.enumerated().map { index, photo in
            let path = try fileStorageService.saveImage(photo.image, fileName: "\(id)_photo_\(index)")
            return PhotoObject(
                imagePath: path,
                latitude: photo.location?.coordinate.latitude,
                longitude: photo.location?.coordinate.longitude
            )
        }
        
        let pathCoordinates = entity.pathCoordinates.map {
            CoordinateObject(latitude: $0.latitude, longitude: $0.longitude)
        }
        
        let startLocation = LocationObject(from: entity.startLocation)
        let endLocation = LocationObject(from: entity.endLocation)
        
        /// 산책 데이터
        let record = WalkRecordObject(
            id: id,
            isBookmarked: entity.isBookmarked,
            weatherSymbol: entity.weatherSymbol,
            weatherDescription: entity.weatherDescription,
            temperature: entity.temperature,
            startTime: entity.startTime,
            endTime: entity.endTime,
            startLocation: startLocation,
            endLocation: endLocation,
            duration: entity.duration,
            distance: entity.distance,
            startDate: entity.startDate,
            pathCoordinates: pathCoordinates,
            photos: photoObjects,
            emotion: entity.emotion,
            recordTitle: entity.recordTitle,
            content: entity.content,
            thumbnailImagePath: thumbnailPath
        )
        
        /// 위젯 정보
        let widgetObject = WidgetCalendarObject(
            id: entity.id,
            date: entity.startDate,
            emotion: entity.emotion
        )
        
        do {
            try widgetCalendarService.save(widgetObject)
            try storageService.save(record)
            WidgetCenter.shared.reloadTimelines(ofKind: "StepicWidget")
        } catch {
            throw StorageError.realmSaveFailed
        }
    }
    
    func updateBookmark(entity: WalkDiaryEntity) throws {
        try storageService.updateBookmark(id: entity.id, isBookmarked: entity.isBookmarked)
    }
    
    func fetchAll() -> [WalkDiaryEntity] {
        let objects = storageService.fetchAll()
        return objects.compactMap { convert(object: $0) }
    }
    
    func fetch(byYear year: Int, month: Int) -> [WalkDiaryEntity] {
        let objects = storageService.fetch(byYear: year, month: month)
        return objects.compactMap { convert(object: $0) }
    }
    
    func fetchBookmarked() -> [WalkDiaryEntity] {
        let objects = storageService.fetchBookmarked()
        return objects.compactMap { convert(object: $0) }
    }
    
    func fetch(by id: String) throws -> WalkDiaryEntity {
        let object = try storageService.fetch(by: id)
        guard let entity = convert(object: object) else {
            throw StorageError.realmLoadFailed
        }
        return entity
    }
    
    func delete(entity: WalkDiaryEntity) throws {
        do {
            let thumbPath = "\(entity.id)_thumbnail"
            try fileStorageService.deleteImage(fileName: thumbPath)

            for (index, _) in entity.photos.enumerated() {
                let photoPath = "\(entity.id)_photo_\(index)"
                try fileStorageService.deleteImage(fileName: photoPath)
            }
        } catch {
            throw StorageError.imageDeleteFailed
        }
        
        do {
            try widgetCalendarService.delete(by: entity.id)
            try storageService.delete(by: entity.id)
            WidgetCenter.shared.reloadTimelines(ofKind: "StepicWidget")
        } catch {
            throw StorageError.realmDeleteFailed
        }
    }
    
    private func convert(object: WalkRecordObject) -> WalkDiaryEntity? {
        do {
            
            let thumbImage = try fileStorageService.loadImage(from: object.thumbnailImagePath)
            
            let coordinates = Array(object.pathCoordinates.map {
                CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
            })
            
            let photoEntities: [WalkPhotoEntity] = try object.photos.map { photoObj in
                let image = try fileStorageService.loadImage(from: photoObj.imagePath)
                let location: CLLocation? = {
                    if let lat = photoObj.latitude, let lng = photoObj.longitude {
                        return CLLocation(latitude: lat, longitude: lng)
                    }
                    return nil
                }()
                return WalkPhotoEntity(image: image, location: location)
            }
            
            guard
                let startLocation = object.startLocation,
                let endLocation = object.endLocation else {
                throw StorageError.realmLoadFailed
            }
            
            let startLocationEntity = LocationEntity(
                city: startLocation.city,
                district: startLocation.district,
                street: startLocation.street
            )
            
            let endLocationEntity = LocationEntity(
                city: endLocation.city,
                district: endLocation.district,
                street: endLocation.street
            )
            
            return WalkDiaryEntity(
                id: object.id,
                isBookmarked: object.isBookmarked,
                weatherSymbol: object.weatherSymbol,
                weatherDescription: object.weatherDescription,
                temperature: object.temperature,
                startTime: object.startTime,
                endTime: object.endTime,
                startLocation: startLocationEntity,
                endLocation: endLocationEntity,
                duration: object.duration,
                distance: object.distance,
                startDate: object.startDate,
                pathCoordinates: coordinates,
                photos: photoEntities,
                emotion: object.emotion,
                recordTitle: object.recordTitle,
                content: object.content,
                thumbnailImage: thumbImage
            )
        } catch {
            return nil
        }
    }
}
