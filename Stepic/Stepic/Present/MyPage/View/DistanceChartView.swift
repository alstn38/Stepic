//
//  DistanceChartView.swift
//  Stepic
//
//  Created by 강민수 on 4/6/25.
//

import SwiftUI

struct DistanceChartView: View {
    
    let data: [DistanceChartPoint]

    private var maxDistance: Double {
        let maxValue = data.map { Double(round($0.distance * 100) / 100) }.max() ?? 0
        return max(maxValue, 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            HStack(spacing: 4) {
                Image(systemName: "map")
                    .resizable()
                    .tint(.textPrimary)
                    .frame(width: 20, height: 20)
                Text(verbatim: .StringLiterals.MyPage.walkDistanceTitle)
                    .font(.callout)
                    .bold()
            }
            .padding(.top, 12)

            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                let spacing = width / CGFloat(max(data.count - 1, 1))

                ZStack {
                    Path { path in
                        for index in data.indices {
                            let point = data[index]
                            let x = CGFloat(index) * spacing
                            let distance = Double(round(point.distance * 100) / 100)
                            let y = height * (1 - CGFloat(distance) / CGFloat(maxDistance))

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
                        let distance = Double(round(point.distance * 100) / 100)
                        let y = height * (1 - CGFloat(distance) / CGFloat(maxDistance))

                        Circle()
                            .fill(point.isMax ? Color.accentPrimary : Color.textSecondary)
                            .frame(width: 6, height: 6)
                            .position(x: x, y: y)

                        if point.isMax {
                            Text("\(String(format: "%.0f", distance))km")
                                .font(.caption2)
                                .foregroundColor(.textPrimary)
                                .position(x: x, y: y - 14)
                        }
                    }
                }
            }
            .frame(height: 100)
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 8)
        .background(Color(uiColor: .backgroundSecondary))
        .cornerRadius(10)
    }
}
