//
//  String+.swift
//  Stepic
//
//  Created by 강민수 on 4/7/25.
//

import UIKit

extension String {
    
    static func combinedString(_ first: String, _ second: String) -> String {
        let trimmedFirst = first.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSecond = second.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let hasFirst = !trimmedFirst.isEmpty
        let hasSecond = !trimmedSecond.isEmpty
        
        switch (hasFirst, hasSecond) {
        case (true, true):
            if trimmedFirst == trimmedSecond {
                return trimmedFirst
            } else {
                return "\(trimmedFirst) \(trimmedSecond)"
            }
        case (true, false):
            return trimmedFirst
        case (false, true):
            return trimmedSecond
        default:
            return .StringLiterals.Common.unknown
        }
    }
}
