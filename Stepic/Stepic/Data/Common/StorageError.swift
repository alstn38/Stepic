//
//  StorageError.swift
//  Stepic
//
//  Created by 강민수 on 4/4/25.
//

import Foundation

enum StorageError: Error, LocalizedError {
    case realmSaveFailed
    case realmLoadFailed
    case imageSaveFailed
    case imageLoadFailed
}

extension StorageError {
    var errorDescription: String? {
        switch self {
        case .realmSaveFailed:
            return .StringLiterals.Storage.realmSaveFailedMessage
        case .realmLoadFailed:
            return .StringLiterals.Storage.realmLoadFailedMessage
        case .imageSaveFailed:
            return .StringLiterals.Storage.imageSaveFailedMessage
        case .imageLoadFailed:
            return .StringLiterals.Storage.imageLoadFailedMessage
        }
    }
}
