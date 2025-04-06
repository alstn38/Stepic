//
//  ImageFileStorageService.swift
//  Stepic
//
//  Created by 강민수 on 4/4/25.
//

import UIKit

protocol ImageFileStorageService {
    func saveImage(_ image: UIImage, fileName: String) throws -> String
    func loadImage(from path: String) throws -> UIImage
    func deleteImage(fileName: String) throws
}

final class DefaultImageFileStorageService: ImageFileStorageService {
    
    private let fileManager = FileManager.default
    private let directoryName = "StepicImages"
    
    func saveImage(_ image: UIImage, fileName: String) throws -> String {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw StorageError.imageSaveFailed
        }
        
        do {
            let documentsDirectory = try fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            
            let directory = documentsDirectory.appendingPathComponent(directoryName)
            
            if !fileManager.fileExists(atPath: directory.path) {
                try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            }
            
            let fileURL = directory.appendingPathComponent("\(fileName).jpg")
            try data.write(to: fileURL)
            
            return "\(directoryName)/\(fileName).jpg"
        } catch {
            throw StorageError.imageSaveFailed
        }
    }
    
    func loadImage(from relativePath: String) throws -> UIImage {
        let documentsDirectory = try fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        let fileURL = documentsDirectory.appendingPathComponent(relativePath)
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            throw StorageError.imageLoadFailed
        }
        
        let data = try Data(contentsOf: fileURL)
        guard let image = UIImage(data: data) else {
            throw StorageError.imageLoadFailed
        }
        
        return image
    }
    
    func deleteImage(fileName: String) throws {
        do {
            let documentsDirectory = try fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )
            let fileURL = documentsDirectory.appendingPathComponent("\(directoryName)/\(fileName).jpg")

            if fileManager.fileExists(atPath: fileURL.path) {
                try fileManager.removeItem(at: fileURL)
            }
        } catch {
            throw StorageError.imageDeleteFailed
        }
    }
}
