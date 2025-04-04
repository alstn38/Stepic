//
//  ImageFileStorageService.swift
//  Stepic
//
//  Created by 강민수 on 4/4/25.
//

import UIKit

protocol ImageFileStorageService {
    func saveImage(_ image: UIImage, fileName: String) throws -> String
}

final class DefaultImageFileStorageService: ImageFileStorageService {
    
    private let fileManager = FileManager.default
    private let directoryName = "StepicImages"

    func saveImage(_ image: UIImage, fileName: String) throws -> String {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw StorageError.imageSaveFailed
        }

        do {
            let directory = try fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            ).appendingPathComponent(directoryName)
            
            if !fileManager.fileExists(atPath: directory.path) {
                try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            }
            
            let fileURL = directory.appendingPathComponent("\(fileName).jpg")
            try data.write(to: fileURL)
            return fileURL.path
        } catch {
            throw StorageError.imageSaveFailed
        }
    }
}
