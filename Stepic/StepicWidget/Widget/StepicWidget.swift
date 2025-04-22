//
//  StepicWidget.swift
//  StepicWidget
//
//  Created by 강민수 on 4/22/25.
//

import WidgetKit
import SwiftUI

struct StepicWidget: Widget {
    let kind: String = "StepicWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WidgetCalendarTimelineProvider()) { entry in
            if #available(iOS 17.0, *) {
                WeeklyCalendarWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                WeeklyCalendarWidgetView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .supportedFamilies([.systemMedium])
        .configurationDisplayName("이번 주 감정 캘린더")
        .description("최근 일주일 동안의 감정 기록을 캘린더 형태로 보여줍니다.")
    }
}
