//
//  DistanceChartPoint.swift
//  Stepic
//
//  Created by 강민수 on 4/6/25.
//

import Foundation

struct DistanceChartPoint: Identifiable {
    let id = UUID()
    let day: Int
    let distance: Double
    let isMax: Bool
}
