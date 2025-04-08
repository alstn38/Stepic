//
//  WeatherLocationEntity.swift
//  Stepic
//
//  Created by 강민수 on 4/1/25.
//

import Foundation

struct WeatherLocationEntity {
    let city: String
    let district: String
    let street: String
    
    let symbolName: String
    let description: String
    let temperature: String
}

extension WeatherLocationEntity {
    
    static func loadingDummy() -> WeatherLocationEntity {
        return WeatherLocationEntity(
            city: "",
            district: "",
            street: "",
            symbolName: "",
            description: "",
            temperature: ""
        )
    }
}
