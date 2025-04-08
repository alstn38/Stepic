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
        enum Common {
            static let unknown: String = localized("unknown")
            static let weatherInfoSource: String = localized("weatherInfoSource")
            static let genericAlertConfirm: String = localized("genericAlertConfirm")
        }
        
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
            static let inputRequiredTitle: String = localized("inputRequiredTitle")
            static let walkEmotionSelectMessage: String = localized("walkEmotionSelectMessage")
            static let walkTitleSettingMessage: String = localized("walkTitleSettingMessage")
        }
        
        enum MyPage {
            static let totalTimeTitle: String = localized("totalTimeTitle")
            static let totalDistanceTitle: String = localized("totalDistanceTitle")
            static let allWalkTitle: String = localized("allWalkTitle")
            static let monthWalkTitle: String = localized("monthWalkTitle")
            static let boomMarkTitle: String = localized("boomMarkTitle")
            static let walkCountFormat: String = localized("walkCountFormat")
            static let statisticsTitle: String = localized("statisticsTitle")
            static let emotionTitle: String = localized("emotionTitle")
            static let walkDurationTitle: String = localized("walkDurationTitle")
            static let walkDistanceTitle: String = localized("walkDistanceTitle")
        }
        
        enum Alert {
            static let locationAlertTitle: String = localized("locationAlertTitle")
            static let locationAlertMessage: String = localized("locationAlertMessage")
            static let locationAlertGoToSetting: String = localized("locationAlertGoToSetting")
            static let locationAlertCancel: String = localized("locationAlertCancel")
            static let genericAlertConfirm: String = localized("genericAlertConfirm")
            static let photoLimitAlertTitle: String = localized("photoLimitAlertTitle")
            static let photoLimitAlertMessage: String = localized("photoLimitAlertMessage")
            static let photoActionCamera: String = localized("photoActionCamera")
            static let photoActionLibrary: String = localized("photoActionLibrary")
            static let storageErrorAlertTitle: String = localized("storageErrorAlertTitle")
            static let mapThumbnailSaveFailedMessage: String = localized("mapThumbnailSaveFailedMessage")
            static let selectDateTitle: String = localized("selectDateTitle")
            static let alertSave: String = localized("alertSave")
            static let walkSaveWarningMessage: String = localized("walkSaveWarningMessage")
            static let deleteActionTitle: String = localized("deleteActionTitle")
            static let deleteSuccessMessage: String = localized("deleteSuccessMessage")
            static let deleteAlertTitle: String = localized("deleteAlertTitle")
            static let deleteAlertMessage: String = localized("deleteAlertMessage")
        }
        
        enum Toast {
            static let walkFinishHoldMessage: String = localized("walkFinishHoldMessage")
        }
        
        enum Formatter {
            static let timeFormat: String = localized("timeFormat")
            static let dateFormat: String = localized("dateFormat")
        }
        
        enum Storage {
            static let realmSaveFailedMessage: String = localized("realmSaveFailedMessage")
            static let realmLoadFailedMessage: String = localized("realmLoadFailedMessage")
            static let realmDeleteFailed: String = localized("realmDeleteFailed")
            static let imageSaveFailedMessage: String = localized("imageSaveFailedMessage")
            static let imageLoadFailedMessage: String = localized("imageLoadFailedMessage")
            static let imageDeleteFailedMessage: String = localized("imageDeleteFailedMessage")
        }
        
        enum Setting {
            static let settingsTitle: String = localized("settingsTitle")
            static let termsOfServiceTitle: String = localized("termsOfServiceTitle")
            static let privacyPolicyTitle: String = localized("privacyPolicyTitle")
            static let contactUsTitle: String = localized("contactUsTitle")
            static let termsAndContactSectionTitle: String = localized("termsAndContactSectionTitle")
            static let appInfoSectionTitle: String = localized("appInfoSectionTitle")
            static let versionLabel: String = localized("versionLabel")
        }
        
        enum WalkSummary {
            static let searchPlaceholder: String = localized("searchPlaceholder")
        }
    }
}
