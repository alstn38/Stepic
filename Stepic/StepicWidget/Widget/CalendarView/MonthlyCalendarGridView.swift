//
//  MonthlyCalendarGridView.swift
//  Stepic
//
//  Created by 강민수 on 4/23/25.
//

import SwiftUI

struct MonthlyCalendarGridView: View {
    let entry: CalendarEntry
    private let imageNames = [
        "loveEmoji", "happyEmoji", "neutralEmoji",
        "tiredEmoji", "sadEmoji", "angryEmoji"
    ]
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        VStack(spacing: 14) {
            Text(formattedCurrentMonth())
                .font(.title3)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .center)

            HStack(spacing: 4) {
                ForEach(0..<7, id: \.self) { idx in
                    Text(weekdaySymbol(for: idx))
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 8)

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(paddedDayItems(), id: \.id) { item in
                    if let day = item.day {
                        let isToday = isToday(day: day)
                        if let emotionIndex = entry.monthlyEmotions[day],
                           emotionIndex < imageNames.count {
                            Image(imageNames[emotionIndex])
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.primary)
                        } else {
                            Text("\(day)")
                                .font(.headline)
                                .fontWeight(isToday ? .bold : .regular)
                                .foregroundColor(isToday ? .green : .secondary)
                        }
                    } else {
                        Spacer(minLength: 18)
                    }
                }
            }
        }
        .padding(8)
    }

    /// 날짜 배열 생성, 시작 offset 반영하는 메서드
    private func paddedDayItems() -> [DayItem] {
        let range = calendar.range(of: .day, in: .month, for: entry.date)!
        let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: entry.date))!
        let offset = calendar.component(.weekday, from: firstOfMonth) - 1

        let leading = (0..<offset).map { _ in DayItem(day: nil) }
        let days = range.map { DayItem(day: $0) }
        return leading + days
    }

    /// 현재 연/월 문자열 시스템 언어 기준 출력하는 메서드
    private func formattedCurrentMonth() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("yyyyMMMM")
        return formatter.string(from: entry.date)
    }

    /// 요일 문자열(일, 월, 화...) 시스템 언어 기준 출력하는 메서드
    private func weekdaySymbol(for index: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.veryShortWeekdaySymbols[index]
    }

    /// 오늘 날짜인지 확인하는 메서드
    private func isToday(day: Int) -> Bool {
        guard
            let start = calendar.date(from: calendar.dateComponents([.year, .month], from: entry.date)),
            let d = calendar.date(byAdding: .day, value: day - 1, to: start)
        else { return false }
        return calendar.isDateInToday(d)
    }
}
