//
//  WalkDurationChartView.swift
//  Stepic
//
//  Created by 강민수 on 4/6/25.
//

import SwiftUI

struct WalkDurationChartView: View {
    
    let data: [DurationChartPoint]

    private var maxDuration: Int {
        let maxValue = data.map { Int($0.duration.rounded()) }.max() ?? 0
        return max(maxValue, 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .resizable()
                    .tint(.textPrimary)
                    .frame(width: 20, height: 20)
                Text(verbatim: .StringLiterals.MyPage.walkDurationTitle)
                    .font(.callout)
                    .bold()
            }

            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                let spacing = width / CGFloat(max(data.count - 1, 1))

                ZStack {
                    Path { path in
                        for index in data.indices {
                            let point = data[index]
                            let x = CGFloat(index) * spacing
                            let intDuration = Int(point.duration.rounded())
                            let y = height * (1 - CGFloat(intDuration) / CGFloat(maxDuration))

                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(Color.textPlaceholder, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

                    ForEach(data.indices, id: \.self) { index in
                        let point = data[index]
                        let x = CGFloat(index) * spacing
                        let intDuration = Int(point.duration.rounded())
                        let y = height * (1 - CGFloat(intDuration) / CGFloat(maxDuration))

                        Circle()
                            .fill(point.isMax ? Color.accentPrimary : Color.textSecondary)
                            .frame(width: 6, height: 6)
                            .position(x: x, y: y)

                        if point.isMax {
                            Text(DateFormatManager.shared.formattedDurationTime(from: point.duration))
                                .font(.caption2)
                                .foregroundColor(.textPrimary)
                                .position(x: x, y: y - 14)
                            
                            Text(ordinalString(for: point.day))
                                .font(.caption2)
                                .foregroundColor(.textPlaceholder)
                                .position(x: x, y: y + 14)
                        }
                    }
                }
            }
            .frame(height: 100)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(Color(uiColor: .backgroundSecondary))
        .cornerRadius(10)
    }
    
    private func ordinalString(for day: Int) -> String {
        let locale = Locale.current
        if locale.identifier.hasPrefix("ko") {
            return "\(day)일"
        } else {
            let formatter = NumberFormatter()
            formatter.numberStyle = .ordinal
            formatter.locale = locale
            return formatter.string(from: NSNumber(value: day)) ?? "\(day)"
        }
    }
}
