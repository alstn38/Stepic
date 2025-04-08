//
//  HomeRecordSection.swift
//  Stepic
//
//  Created by 강민수 on 4/5/25.
//

import Foundation

import RxDataSources

struct HomeRecordSection {
    var items: [WalkDiaryEntity]
}

extension HomeRecordSection: SectionModelType {
    
    init(original: HomeRecordSection, items: [WalkDiaryEntity]) {
        self = original
        self.items = items
    }
}
