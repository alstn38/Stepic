//
//  MyPageInfoViewItem.swift
//  Stepic
//
//  Created by 강민수 on 4/5/25.
//

import Foundation

struct MyPageInfoViewItem {
    let totalTime: TimeInterval
    let totalDistance: Double
    let totalWalkCount: Int
    let monthWalkCount: Int
    let bookMarkWalkCount: Int
}

extension MyPageInfoViewItem {
    
    static func dummy() -> MyPageInfoViewItem {
        return MyPageInfoViewItem(
            totalTime: 0,
            totalDistance: 0,
            totalWalkCount: 0,
            monthWalkCount: 0,
            bookMarkWalkCount: 0
        )
    }
}
