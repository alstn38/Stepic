//
//  InputOutputModel.swift
//  Stepic
//
//  Created by 강민수 on 4/1/25.
//

import Foundation

protocol InputOutputModel {
    associatedtype Input
    associatedtype Output
    
    func transform(from input: Input) -> Output
}
