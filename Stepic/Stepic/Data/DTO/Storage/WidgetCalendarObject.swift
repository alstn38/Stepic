//
//  WidgetCalendarObject.swift
//  Stepic
//
//  Created by 강민수 on 4/22/25.
//

import Foundation

import RealmSwift

final class WidgetCalendarObject: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var startDate: Date
    @Persisted var emotion: Int

    convenience init(id: String, date: Date, emotion: Int) {
        self.init()
        self.id = id
        self.startDate = date
        self.emotion = emotion
    }
}
