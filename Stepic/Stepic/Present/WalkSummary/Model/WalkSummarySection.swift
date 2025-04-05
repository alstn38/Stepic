//
//  WalkSummarySection.swift
//  Stepic
//
//  Created by 강민수 on 4/5/25.
//

import Foundation

import RxDataSources

struct WalkSummarySection {
    var items: [WalkDiaryEntity]
}

extension WalkSummarySection: SectionModelType {
    
    init(original: WalkSummarySection, items: [WalkDiaryEntity]) {
        self = original
        self.items = items
    }
}
