//
//  UIImage+.swift
//  Stepic
//
//  Created by 강민수 on 3/30/25.
//

import UIKit

extension UIImage {
    func resize(to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        self.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()
        return resizedImage.withRenderingMode(.alwaysTemplate)
    }
}
