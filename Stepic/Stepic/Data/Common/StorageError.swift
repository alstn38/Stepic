//
//  StorageError.swift
//  Stepic
//
//  Created by 강민수 on 4/4/25.
//

import Foundation

enum StorageError: Error, LocalizedError {
    case realmSaveFailed
    case imageSaveFailed
}

extension StorageError {
    var errorDescription: String? {
        switch self {
        case .realmSaveFailed:
            return .StringLiterals.Storage.realmSaveFailedMessage
        case .imageSaveFailed:
            return .StringLiterals.Storage.imageSaveFailedMessage
        }
    }
}
