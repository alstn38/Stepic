//
//  ReusableViewProtocol.swift
//  Stepic
//
//  Created by 강민수 on 3/28/25.
//

import Foundation

protocol ReusableViewProtocol {
    static var identifier: String { get }
}

extension ReusableViewProtocol {
    static var identifier: String {
        return String(describing: self)
    }
}
