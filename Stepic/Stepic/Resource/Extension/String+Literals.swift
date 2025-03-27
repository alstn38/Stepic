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
    }
}
