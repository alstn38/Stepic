//
//  WeeklyCalendarWidgetView.swift
//  Stepic
//
//  Created by 강민수 on 4/23/25.
//

import SwiftUI

struct WeeklyCalendarWidgetView: View {
    let entry: CalendarEntry

    private let imageNames = [
        "loveEmoji", "happyEmoji", "neutralEmoji",
        "tiredEmoji", "sadEmoji", "angryEmoji"
    ]

    var body: some View {
        VStack(spacing: 12) {
            Text(formattedCurrentMonth())
                .font(.headline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            HStack(spacing: 8) {
                ForEach(0..<7, id: \.self) { index in
                    Text(weekdaySymbol(for: index))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            HStack(spacing: 8) {
                ForEach(0..<7, id: \.self) { index in
                    VStack {
                        if let emotionIndex = entry.weeklyEmotions[index],
                           emotionIndex < imageNames.count {
                            Image(imageNames[emotionIndex])
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.primary)
                                .frame(width: 28, height: 28)
                        } else {
                            let dateString = dayNumberOfWeekday(index)
                            let isToday = isToday(weekdayIndex: index)

                            Text(dateString)
                                .font(.callout)
                                .foregroundColor(isToday ? .green : .secondary)
                                .fontWeight(isToday ? .bold : .regular)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
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
    private func isToday(weekdayIndex: Int) -> Bool {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: entry.date)
        components.weekday = weekdayIndex + 1
        guard let date = calendar.date(from: components) else { return false }

        return calendar.isDateInToday(date)
    }

    /// 이미지 없을 경우 해당 날짜 숫자 반환하는 메서드
    private func dayNumberOfWeekday(_ index: Int) -> String {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: entry.date)
        components.weekday = index + 1

        let date = calendar.date(from: components)
        let day = calendar.component(.day, from: date ?? entry.date)
        return "\(day)"
    }
}
