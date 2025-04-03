//
//  EmotionTypeEntity.swift
//  Stepic
//
//  Created by 강민수 on 4/3/25.
//

import UIKit

enum EmotionTypeEntity: Int, CaseIterable {
    case love
    case happy
    case neutral
    case tired
    case sad
    case angry
    
    var title: String {
        switch self {
        case .love:
            return .StringLiterals.Detail.loveButtonTitle
        case .happy:
            return .StringLiterals.Detail.happyButtonTitle
        case .neutral:
            return .StringLiterals.Detail.neutralButtonTitle
        case .tired:
            return .StringLiterals.Detail.tiredButtonTitle
        case .sad:
            return .StringLiterals.Detail.sadButtonTitle
        case .angry:
            return .StringLiterals.Detail.angryButtonTitle
        }
    }
    
    var image: UIImage {
        switch self {
        case .love:
            return .loveEmoji
        case .happy:
            return .happyEmoji
        case .neutral:
            return .neutralEmoji
        case .tired:
            return .tiredEmoji
        case .sad:
            return .sadEmoji
        case .angry:
            return .angryEmoji
        }
    }
}
