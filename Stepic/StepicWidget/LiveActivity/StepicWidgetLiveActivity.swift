//
//  StepicWidgetLiveActivity.swift
//  StepicWidget
//
//  Created by 강민수 on 4/22/25.
//

//import ActivityKit
//import WidgetKit
//import SwiftUI

//struct StepicWidgetAttributes: ActivityAttributes {
//    public struct ContentState: Codable, Hashable {
//        // Dynamic stateful properties about your activity go here!
//        var emoji: String
//    }
//
//    // Fixed non-changing properties about your activity go here!
//    var name: String
//}
//
//struct StepicWidgetLiveActivity: Widget {
//    var body: some WidgetConfiguration {
//        ActivityConfiguration(for: StepicWidgetAttributes.self) { context in
//            // Lock screen/banner UI goes here
//            VStack {
//                Text("Hello \(context.state.emoji)")
//            }
//            .activityBackgroundTint(Color.cyan)
//            .activitySystemActionForegroundColor(Color.black)
//
//        } dynamicIsland: { context in
//            DynamicIsland {
//                // Expanded UI goes here.  Compose the expanded UI through
//                // various regions, like leading/trailing/center/bottom
//                DynamicIslandExpandedRegion(.leading) {
//                    Text("Leading")
//                }
//                DynamicIslandExpandedRegion(.trailing) {
//                    Text("Trailing")
//                }
//                DynamicIslandExpandedRegion(.bottom) {
//                    Text("Bottom \(context.state.emoji)")
//                    // more content
//                }
//            } compactLeading: {
//                Text("L")
//            } compactTrailing: {
//                Text("T \(context.state.emoji)")
//            } minimal: {
//                Text(context.state.emoji)
//            }
//            .widgetURL(URL(string: "http://www.apple.com"))
//            .keylineTint(Color.red)
//        }
//    }
//}
//
//extension StepicWidgetAttributes {
//    fileprivate static var preview: StepicWidgetAttributes {
//        StepicWidgetAttributes(name: "World")
//    }
//}
//
//extension StepicWidgetAttributes.ContentState {
//    fileprivate static var smiley: StepicWidgetAttributes.ContentState {
//        StepicWidgetAttributes.ContentState(emoji: "😀")
//     }
//     
//     fileprivate static var starEyes: StepicWidgetAttributes.ContentState {
//         StepicWidgetAttributes.ContentState(emoji: "🤩")
//     }
//}

//#Preview("Notification", as: .content, using: StepicWidgetAttributes.preview) {
//   StepicWidgetLiveActivity()
//} contentStates: {
//    StepicWidgetAttributes.ContentState.smiley
//    StepicWidgetAttributes.ContentState.starEyes
//}
