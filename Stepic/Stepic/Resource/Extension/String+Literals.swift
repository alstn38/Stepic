//
//  String+Literals.swift
//  Stepic
//
//  Created by 강민수 on 3/27/25.
//

import Foundation

extension String {
    
    static func localized(_ key: String) -> String {
        return String(localized: String.LocalizationValue(key))
    }
}

extension String {
    
    enum StringLiterals {
        enum TabBar {
            static let homeTitle: String = localized("tapBarHomeTitle")
            static let myPageTitle: String = localized("tapBarMyPageTitle")
        }
        
        enum Home {
            static let walkButtonTitle: String = localized("homeWalkButton")
            static let emotionTitle: String = localized("emotionTitle")
            static let timeTitle: String = localized("timeTitle")
            static let distanceTitle: String = localized("distanceTitle")
            static let recordTitle: String = localized("recordTitle")
        }
        
        enum Walk {
            static let timeTitle: String = localized("timeTitle")
            static let distanceTitle: String = localized("distanceTitle")
        }
        
        enum Detail {
            static let walkInfoTitle: String = localized("walkInfoTitle")
            static let weatherTitle: String = localized("weatherTitle")
            static let startingPointTitle: String = localized("startingPointTitle")
            static let endingPointTitle: String = localized("endingPointTitle")
            static let startTimeTitle: String = localized("startTimeTitle")
            static let endTimeTitle: String = localized("endTimeTitle")
            static let durationTimeTitle: String = localized("durationTimeTitle")
            static let distanceTitle: String = localized("distanceTitle")
        }
    }
}
