//
//  EmotionBarChartView.swift
//  Stepic
//
//  Created by 강민수 on 4/6/25.
//

import SwiftUI

struct EmotionBarChartView: View {
    var emotions: [EmotionCount]

    private var maxCount: Int {
        emotions.map { $0.count }.max() ?? 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            HStack(spacing: 4) {
                Image(systemName: "face.smiling")
                    .resizable()
                    .tint(.textPrimary)
                    .frame(width: 20, height: 20)
                Text(verbatim: .StringLiterals.MyPage.emotionTitle)
                    .font(.callout)
                    .bold()
            }

            HStack(alignment: .bottom, spacing: 15) {
                ForEach(emotions) { item in
                    VStack {
                        Text("\(item.count)")
                            .font(.caption2)
                            .foregroundColor(.textPrimary)
                            .padding(.bottom, 2)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(item.isMostFrequent ? Color.accentPrimary : Color.textPlaceholder)
                            .frame(width: 10, height: CGFloat(item.count) / CGFloat(maxCount) * 100)
                            .frame(maxWidth: .infinity)

                        item.emotion.swiftUIImage
                            .resizable()
                            .interpolation(.high)
                            .frame(width: 18, height: 18)
                            .padding(.top, 4)

                        Text(item.emotion.title)
                            .font(.caption2)
                            .multilineTextAlignment(.center)
                    }
                }
            }
        }
        .padding(.horizontal, 18)
        .background(Color(uiColor: .backgroundSecondary))
        .cornerRadius(10)
    }
}
