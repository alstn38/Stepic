//
//  UIStackView+.swift
//  Stepic
//
//  Created by 강민수 on 3/27/25.
//

import UIKit

extension UIStackView {
    
    func addArrangedSubviews(_ views: UIView...) {
        for view in views {
            self.addArrangedSubview(view)
        }
    }
}
