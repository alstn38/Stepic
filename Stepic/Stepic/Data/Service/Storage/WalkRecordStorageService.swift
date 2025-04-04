//
//  WalkRecordStorageService.swift
//  Stepic
//
//  Created by 강민수 on 4/4/25.
//

import Foundation

import RealmSwift

protocol WalkRecordStorageService {
    func save(_ object: WalkRecordObject) throws
}

final class DefaultWalkRecordStorageService: WalkRecordStorageService {
    private let realm = try! Realm()
    
    func save(_ object: WalkRecordObject) throws {
        do {
            try realm.write {
                realm.add(object, update: .all)
            }
        } catch {
            throw StorageError.realmSaveFailed
        }
    }
}
