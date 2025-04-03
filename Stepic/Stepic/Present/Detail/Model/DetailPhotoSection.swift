//
//  DetailPhotoSection.swift
//  Stepic
//
//  Created by 강민수 on 4/3/25.
//

import Foundation

import RxDataSources

enum DetailPhotoItem {
    case photo(WalkPhotoEntity)
    case addPlaceholder
}

struct DetailPhotoSection {
    var items: [DetailPhotoItem]
}

extension DetailPhotoSection: SectionModelType {
    
    init(original: DetailPhotoSection, items: [DetailPhotoItem]) {
        self = original
        self.items = items
    }
}
