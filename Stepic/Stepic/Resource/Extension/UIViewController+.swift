//
//  UIViewController+.swift
//  Stepic
//
//  Created by 강민수 on 3/28/25.
//

import UIKit

extension UIViewController {
    
    func configureMainButtonButtonConfiguration(title: String) -> UIButton.Configuration {
        var titleContainer = AttributeContainer()
        titleContainer.font = .titleSmall
        
        var configuration = UIButton.Configuration.filled()
        configuration.attributedTitle = AttributedString(title, attributes: titleContainer)
        configuration.baseBackgroundColor = .accentPrimary
        configuration.baseForegroundColor = .white
        
        return configuration
    }
}
