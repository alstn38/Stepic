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
    func fetchAll() -> [WalkRecordObject]
    func fetch(byYear year: Int, month: Int) -> [WalkRecordObject]
    func fetchBookmarked() -> [WalkRecordObject]
    func fetch(by id: String) throws -> WalkRecordObject
    func updateBookmark(id: String, isBookmarked: Bool) throws
    func delete(by id: String) throws
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
    
    func fetchAll() -> [WalkRecordObject] {
        return Array(
            realm.objects(WalkRecordObject.self)
                .sorted(byKeyPath: "startTime", ascending: false)
        )
    }
    
    func fetch(byYear year: Int, month: Int) -> [WalkRecordObject] {
        let calendar = Calendar.current
        guard
            let startDate = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
            let endDate = calendar.date(byAdding: .month, value: 1, to: startDate)?.addingTimeInterval(-1)
        else { return [] }
        
        let results = realm.objects(WalkRecordObject.self)
            .where { $0.startDate >= startDate && $0.startDate <= endDate }
            .sorted(byKeyPath: "startTime", ascending: false)
        
        return Array(results)
    }
    
    func fetchBookmarked() -> [WalkRecordObject] {
        let results = realm.objects(WalkRecordObject.self)
            .where { $0.isBookmarked == true }
            .sorted(byKeyPath: "startTime", ascending: false)

        return Array(results)
    }
    
    func fetch(by id: String) throws -> WalkRecordObject {
        guard let object = realm.object(ofType: WalkRecordObject.self, forPrimaryKey: id) else {
            throw StorageError.realmLoadFailed
        }
        return object
    }
    
    func updateBookmark(id: String, isBookmarked: Bool) throws {
        guard let object = realm.object(ofType: WalkRecordObject.self, forPrimaryKey: id) else {
            throw StorageError.realmLoadFailed
        }
        
        do {
            try realm.write {
                object.isBookmarked = isBookmarked
            }
        } catch {
            throw StorageError.realmSaveFailed
        }
    }
    
    func delete(by id: String) throws {
        guard let object = realm.object(ofType: WalkRecordObject.self, forPrimaryKey: id) else {
            throw StorageError.realmLoadFailed
        }
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            throw StorageError.realmDeleteFailed
        }
    }
}
