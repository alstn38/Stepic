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
    
    private func configureFormatters() {
        dateFormatter.dateFormat = .StringLiterals.Formatter.dateFormat
        timeFormatter.dateFormat = .StringLiterals.Formatter.timeFormat
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
}
