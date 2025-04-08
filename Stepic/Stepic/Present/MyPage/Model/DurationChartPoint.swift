//
//  DurationChartPoint.swift
//  Stepic
//
//  Created by 강민수 on 4/6/25.
//

import Foundation

struct DurationChartPoint: Identifiable {
    let id = UUID()
    let day: Int
    let duration: TimeInterval
    let isMax: Bool
}
