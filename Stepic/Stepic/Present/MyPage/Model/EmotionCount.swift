//
//  EmotionCount.swift
//  Stepic
//
//  Created by 강민수 on 4/6/25.
//

import Foundation

struct EmotionCount: Identifiable {
    let id = UUID()
    let emotion: EmotionTypeEntity
    let count: Int
    let isMostFrequent: Bool
}
