//
//  CalendarEntry.swift
//  Stepic
//
//  Created by 강민수 on 4/23/25.
//

import WidgetKit

struct CalendarEntry: TimelineEntry {
    let date: Date
    
    /// Weekly
    /// key: 요일 - 일월화수목금토일
    /// value: emotion Index
    let weeklyEmotions: [Int:Int]
    
    /// Month
    /// key: 날짜
    /// value: emotion Index
    let monthlyEmotions: [Int:Int]
}
