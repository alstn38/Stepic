//
//  WidgetCalendarTimelineProvider.swift
//  Stepic
//
//  Created by 강민수 on 4/23/25.
//

import WidgetKit

struct WidgetCalendarTimelineProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> WeeklyCalendarEntry {
        WeeklyCalendarEntry(date: Date(), dayEmotions: [:])
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (WeeklyCalendarEntry) -> Void
    ) {
        completion(WeeklyCalendarEntry(date: Date(), dayEmotions: [:]))
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<WeeklyCalendarEntry>) -> Void
    ) {
        let service: WidgetCalendarReadableStorageService = DefaultWidgetCalendarStorageService()
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()

        var dayEmotions: [Int: Int] = [:]

        do {
            let records = try service.fetchRecent7Days()
            for record in records {
                let weekday = calendar.component(.weekday, from: record.startDate)
                let index = weekday - 1
                dayEmotions[index] = record.emotion
            }

            let entry = WeeklyCalendarEntry(date: now, dayEmotions: dayEmotions)
            let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: now)!)
            let timeline = Timeline(entries: [entry], policy: .after(tomorrow))

            completion(timeline)
        } catch {
            let entry = WeeklyCalendarEntry(date: now, dayEmotions: [:])
            completion(Timeline(entries: [entry], policy: .atEnd))
        }
    }
}
