//
//  WidgetMigrationService.swift
//  Stepic
//
//  Created by 강민수 on 4/23/25.
//

import Foundation
import RealmSwift
import WidgetKit

enum WidgetMigrationService {
    
    static func migrateDataToWidgetRealm() {
        
        let migrationKey = "widgetRealmMigrationDone"
        
        guard UserDefaults.standard.bool(forKey: migrationKey) == false else { return }
        
        do {
            let appRealm = try Realm()
            let allRecords = appRealm.objects(WalkRecordObject.self)
            
            guard let containerURL = FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: "group.com.alstn38.Stepic")?
                .appendingPathComponent("Shared.realm") else {
                return
            }
            
            let config = Realm.Configuration(fileURL: containerURL)
            let widgetRealm = try Realm(configuration: config)
            
            try widgetRealm.write {
                for record in allRecords {
                    let widgetObject = WidgetCalendarObject(
                        id: record.id,
                        date: record.startDate,
                        emotion: record.emotion
                    )
                    widgetRealm.add(widgetObject, update: .modified)
                }
            }
            
            UserDefaults.standard.set(true, forKey: migrationKey)
            WidgetCenter.shared.reloadTimelines(ofKind: "StepicWidget")
            return
            
        } catch {
            return
        }
    }
}
