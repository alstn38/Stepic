//
//  AddressDTO.swift
//  Stepic
//
//  Created by 강민수 on 4/1/25.
//

import Foundation

struct AddressDTO {
    let city: String
    let district: String
    let street: String
}

extension AddressDTO {
    
    static func dummy() -> AddressDTO {
        return AddressDTO(
            city: "Unknown",
            district: "Unknown",
            street: "Unknown"
        )
    }
}
