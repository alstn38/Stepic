//
//  UIFont+Literals.swift
//  Stepic
//
//  Created by 강민수 on 3/27/25.
//

import UIKit

extension UIFont {
    
    /// Bold Fonts
    /// 32, bold
    static var titleExtraLarge: UIFont {
        return UIFont.systemFont(ofSize: 32, weight: .bold)
    }

    /// 22, bold
    static var titleLarge: UIFont {
        return UIFont.systemFont(ofSize: 22, weight: .bold)
    }

    /// 20, bold
    static var titleMedium: UIFont {
        return UIFont.systemFont(ofSize: 20, weight: .bold)
    }

    /// 15, bold
    static var titleSmall: UIFont {
        return UIFont.systemFont(ofSize: 15, weight: .bold)
    }

    /// 14, bold
    static var bodyBold: UIFont {
        return UIFont.systemFont(ofSize: 14, weight: .bold)
    }

    /// 12, bold
    static var captionBold: UIFont {
        return UIFont.systemFont(ofSize: 12, weight: .bold)
    }

    /// Regular Fonts
    /// 18, regular
    static var bodyRegular: UIFont {
        return UIFont.systemFont(ofSize: 18, weight: .regular)
    }

    /// 12, regular
    static var captionRegular: UIFont {
        return UIFont.systemFont(ofSize: 12, weight: .regular)
    }
}
