//
//  WeeklyCalendarEntry.swift
//  Stepic
//
//  Created by 강민수 on 4/23/25.
//

import WidgetKit

struct WeeklyCalendarEntry: TimelineEntry {
    let date: Date
    
    /// key: 요일 - 일월화수목금토일
    /// value: emotion Index
    let dayEmotions: [Int: Int]
}
