//
//  WalkPictureSection.swift
//  Stepic
//
//  Created by 강민수 on 4/2/25.
//

import Foundation
import RxDataSources

enum WalkPictureSection {
    case main(items: [WalkPhotoEntity])
}

extension WalkPictureSection: SectionModelType {
    typealias Item = WalkPhotoEntity
    
    var items: [WalkPhotoEntity] {
        switch self {
        case .main(let items): return items
        }
    }
    
    init(original: WalkPictureSection, items: [WalkPhotoEntity]) {
        switch original {
        case .main:
            self = .main(items: items)
        }
    }
}
