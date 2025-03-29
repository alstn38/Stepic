//
//  adjust+.swift
//  Stepic
//
//  Created by 강민수 on 3/29/25.
//

import Foundation

import UIKit

extension CGFloat {
    var adjusted: CGFloat {
        let ratio: CGFloat = UIScreen.main.bounds.width / 393
        let ratioH: CGFloat = UIScreen.main.bounds.height / 852
        return ratio <= ratioH ? self * ratio : self * ratioH
    }
    
    var adjustedWidth: CGFloat {
        let ratio: CGFloat = UIScreen.main.bounds.width / 393
        return CGFloat(self) * ratio
    }
    
    var adjustedHeight: CGFloat {
        let ratio: CGFloat = UIScreen.main.bounds.height / 852
        return CGFloat(self) * ratio
    }
}

extension Int {
    var adjusted: CGFloat {
        let ratio: CGFloat = UIScreen.main.bounds.width / 393
        let ratioH: CGFloat = UIScreen.main.bounds.height / 852
        return ratio <= ratioH ? CGFloat(self) * ratio : CGFloat(self) * ratioH
    }
    
    var adjustedWidth: CGFloat {
        let ratio: CGFloat = UIScreen.main.bounds.width / 393
        return CGFloat(self) * ratio
    }
    
    var adjustedHeight: CGFloat {
        let ratio: CGFloat = UIScreen.main.bounds.height / 852
        return CGFloat(self) * ratio
    }
}

extension Double {
    var adjusted: CGFloat {
        let ratio: CGFloat = UIScreen.main.bounds.width / 393
        let ratioH: CGFloat = UIScreen.main.bounds.height / 852
        return ratio <= ratioH ? CGFloat(self) * ratio : CGFloat(self) * ratioH
    }
    
    var adjustedWidth: CGFloat {
        let ratio: CGFloat = UIScreen.main.bounds.width / 393
        return CGFloat(self) * ratio
    }
    
    var adjustedHeight: CGFloat {
        let ratio: CGFloat = UIScreen.main.bounds.height / 852
        return CGFloat(self) * ratio
    }
}
