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
                StepicWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                StepicWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .configurationDisplayName(String.StringLiterals.Widget.widgetDisplayName)
        .description(String.StringLiterals.Widget.widgetDescription)
    }
}
