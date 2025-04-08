//
//  DateFormatManager.swift
//  Stepic
//
//  Created by 강민수 on 4/3/25.
//

import Foundation

final class DateFormatManager {
    
    static let shared = DateFormatManager()
    
    private init() {
        configureFormatters()
    }
    
    private let dateFormatter = DateFormatter()
    private let timeFormatter = DateFormatter()
    private let selectMonthFormatter = DateFormatter()
    private let monthOnlyFormatter = DateFormatter()
    
    private func configureFormatters() {
        dateFormatter.dateFormat = .StringLiterals.Formatter.dateFormat
        timeFormatter.dateFormat = .StringLiterals.Formatter.timeFormat
        selectMonthFormatter.setLocalizedDateFormatFromTemplate("yyyyMMMM")
        monthOnlyFormatter.setLocalizedDateFormatFromTemplate("MMMM")
    }

    func formattedDate(from date: Date) -> String {
        return dateFormatter.string(from: date)
    }

    func formattedTime(from date: Date) -> String {
        return timeFormatter.string(from: date)
    }
    
    func formattedDurationTime(from timeInterval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute, .second]
        return formatter.string(from: timeInterval) ?? "No Data"
    }
    
    func selectMonthTitle(year: Int, month: Int) -> String {
        var components = DateComponents()
        components.year = year
        components.month = month
        let calendar = Calendar.current
        guard let date = calendar.date(from: components) else { return "" }
        return selectMonthFormatter.string(from: date)
    }
    
    func formattedOnlyMonth(from date: Date) -> String {
        return monthOnlyFormatter.string(from: date)
    }
}
