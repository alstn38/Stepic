//
//  WidgetCalendarTimelineProvider.swift
//  Stepic
//
//  Created by 강민수 on 4/23/25.
//

import WidgetKit

struct WidgetCalendarTimelineProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> CalendarEntry {
        return CalendarEntry(
            date: Date(),
            weeklyEmotions: [:],
            monthlyEmotions: [:]
        )
    }
    
    func getSnapshot(
        in context: Context,
        completion: @escaping (CalendarEntry) -> Void
    ) {
        let entry = CalendarEntry(
            date: Date(),
            weeklyEmotions: [:],
            monthlyEmotions: [:]
        )
        completion(entry)
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<CalendarEntry>) -> Void
    ) {
        let service = DefaultWidgetCalendarStorageService()
        let calendar = Calendar.current
        let now = Date()

        let allRecords = (try? service.fetchCurrentMonth()) ?? []

        var monthly: [Int: Int] = [:]
        for record in allRecords {
            let day = calendar.component(.day, from: record.startDate)
            monthly[day] = record.emotion
        }

        var weekly: [Int: Int] = [:]
        if context.family == .systemMedium {
            let sevenDaysAgo = calendar.date(byAdding: .day, value: -6, to: now)!
            let recent7 = allRecords.filter { $0.startDate >= sevenDaysAgo && $0.startDate <= now }
            for recent in recent7 {
                let weekday = calendar.component(.weekday, from: recent.startDate) - 1
                weekly[weekday] = recent.emotion
            }
        }

        let entry = CalendarEntry(
            date: now,
            weeklyEmotions: weekly,
            monthlyEmotions: monthly
        )

        let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: now)!)
        completion(Timeline(entries: [entry], policy: .after(tomorrow)))
    }
}
