//
//  MonthlyCalendarSmallView.swift
//  Stepic
//
//  Created by 강민수 on 4/23/25.
//

import SwiftUI

struct MonthlyCalendarSmallView: View {
    
    let entry: CalendarEntry
    let imageNames = ["loveEmoji", "happyEmoji", "neutralEmoji", "tiredEmoji", "sadEmoji", "angryEmoji"]

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        VStack(spacing: 6) {
            Text(formattedMonth(entry.date))
                .font(.caption)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(paddedDayItems()) { item in
                    if let day = item.day {
                        let isToday = isToday(day: day)
                        if let emotionIndex = entry.monthlyEmotions[day],
                           emotionIndex < imageNames.count {
                            Image(imageNames[emotionIndex])
                                .resizable()
                                .scaledToFit()
                                .frame(width: 10, height: 10)
                                .foregroundColor(.primary)
                        } else {
                            Text("\(day)")
                                .font(.system(size: 7))
                                .fontWeight(isToday ? .bold : .regular)
                                .foregroundColor(isToday ? .green : .secondary)
                        }
                    } else {
                        Spacer(minLength: 14)
                    }
                }
            }
        }
        .padding(.horizontal, 2)
    }

    /// 날짜 배열 생성, 시작 offset 반영하는 메서드
    private func paddedDayItems() -> [DayItem] {
        let range = calendar.range(of: .day, in: .month, for: entry.date)!
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: entry.date))!
        let weekdayOffset = calendar.component(.weekday, from: firstDay) - 1

        let leading = (0..<weekdayOffset).map { _ in DayItem(day: nil) }
        let days    = range.map { DayItem(day: $0) }

        return leading + days
    }
    
    /// 오늘 날짜인지 확인하는 메서드
    private func isToday(day: Int) -> Bool {
        guard let currentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: entry.date)),
              let date = calendar.date(byAdding: .day, value: day - 1, to: currentMonth)
        else { return false }

        return calendar.isDateInToday(date)
    }

    /// 현재 연/월 문자열 시스템 언어 기준 출력하는 메서드
    private func formattedMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("yyyyMMMM")
        return formatter.string(from: date)
    }
}
