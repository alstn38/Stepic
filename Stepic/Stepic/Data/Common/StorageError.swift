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
    case realmDeleteFailed
    case imageSaveFailed
    case imageLoadFailed
    case imageDeleteFailed
}

extension StorageError {
    var errorDescription: String? {
        switch self {
        case .realmSaveFailed:
            return .StringLiterals.Storage.realmSaveFailedMessage
        case .realmLoadFailed:
            return .StringLiterals.Storage.realmLoadFailedMessage
        case .realmDeleteFailed:
            return .StringLiterals.Storage.realmDeleteFailed
        case .imageSaveFailed:
            return .StringLiterals.Storage.imageSaveFailedMessage
        case .imageLoadFailed:
            return .StringLiterals.Storage.imageLoadFailedMessage
        case .imageDeleteFailed:
            return .StringLiterals.Storage.imageDeleteFailedMessage
        }
    }
}
