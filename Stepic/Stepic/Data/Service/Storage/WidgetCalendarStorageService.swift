//
//  WidgetCalendarStorageService.swift
//  Stepic
//
//  Created by 강민수 on 4/22/25.
//

import Foundation

import RealmSwift

protocol WidgetCalendarWritableStorageService {
    func save(_ object: WidgetCalendarObject) throws
    func delete(by id: String) throws
}

protocol WidgetCalendarReadableStorageService {
    func fetchCurrentMonth() throws -> [WidgetCalendarObject]
}

final class DefaultWidgetCalendarStorageService: WidgetCalendarWritableStorageService, WidgetCalendarReadableStorageService {

    private let realm: Realm

    init() {
        let containerURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.com.alstn38.Stepic")!
            .appendingPathComponent("Shared.realm")

        let config = Realm.Configuration(fileURL: containerURL)
        self.realm = try! Realm(configuration: config)
    }

    func save(_ object: WidgetCalendarObject) throws {
        do {
            try realm.write {
                realm.add(object, update: .all)
            }
        } catch {
            throw StorageError.realmSaveFailed
        }
    }

    func delete(by id: String) throws {
        guard let object = realm.object(ofType: WidgetCalendarObject.self, forPrimaryKey: id) else {
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
    
    func fetchCurrentMonth() throws -> [WidgetCalendarObject] {
        let calendar = Calendar.current
        let now = Date()

        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)
        else {
            return []
        }

        let results = realm.objects(WidgetCalendarObject.self)
            .where {
                $0.startDate >= startOfMonth && $0.startDate <= endOfMonth
            }

        let grouped = Dictionary(grouping: results) {
            calendar.startOfDay(for: $0.startDate)
        }

        let latestPerDay = grouped.compactMapValues { list in
            list.sorted { $0.startDate > $1.startDate }.first
        }

        return latestPerDay
            .sorted { $0.key < $1.key }
            .map { $0.value }
    }
}
