//
//  StepicWidgetEntryView.swift
//  Stepic
//
//  Created by 강민수 on 4/23/25.
//

import SwiftUI

struct StepicWidgetEntryView: View {
    
    @Environment(\.widgetFamily) private var family
    let entry: CalendarEntry

    var body: some View {
        switch family {
        case .systemSmall:
            MonthlyCalendarSmallView(entry: entry)

        case .systemMedium:
            WeeklyCalendarWidgetView(entry: entry)

        case .systemLarge:
            MonthlyCalendarGridView(entry: entry)

        default:
            EmptyView()
        }
    }
}
