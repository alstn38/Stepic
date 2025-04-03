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
            static let recordTitle: String = localized("recordTitle")
            static let loveButtonTitle: String = localized("loveButtonTitle")
            static let happyButtonTitle: String = localized("happyButtonTitle")
            static let neutralButtonTitle: String = localized("neutralButtonTitle")
            static let tiredButtonTitle: String = localized("tiredButtonTitle")
            static let sadButtonTitle: String = localized("sadButtonTitle")
            static let angryButtonTitle: String = localized("angryButtonTitle")
            static let recordTitlePlaceholder: String = localized("recordTitlePlaceholder")
            static let recordContentPlaceholder: String = localized("recordContentPlaceholder")
            static let photoTitle: String = localized("photoTitle")
            static let routeTitle: String = localized("routeTitle")
            static let endWalkButton: String = localized("endWalkButton")
        }
        
        enum MyPage {
            static let totalTimeTitle: String = localized("totalTimeTitle")
            static let totalDistanceTitle: String = localized("totalDistanceTitle")
            static let allWalkTitle: String = localized("allWalkTitle")
            static let monthWalkTitle: String = localized("monthWalkTitle")
            static let boomMarkTitle: String = localized("boomMarkTitle")
        }
        
        enum Alert {
            static let locationAlertTitle: String = localized("locationAlertTitle")
            static let locationAlertMessage: String = localized("locationAlertMessage")
            static let locationAlertGoToSetting: String = localized("locationAlertGoToSetting")
            static let locationAlertCancel: String = localized("locationAlertCancel")
            static let genericAlertConfirm: String = localized("genericAlertConfirm")
            static let photoLimitAlertTitle: String = localized("photoLimitAlertTitle")
            static let photoLimitAlertMessage: String = localized("photoLimitAlertMessage")
        }
        
        enum Toast {
            static let walkFinishHoldMessage: String = localized("walkFinishHoldMessage")
        }
    }
}
