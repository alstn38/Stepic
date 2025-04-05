//
//  WalkResultEntity.swift
//  Stepic
//
//  Created by 강민수 on 4/3/25.
//

import Foundation

struct WalkResultEntity {
    var weather: WeatherLocationEntity
    var tracking: WalkTrackingEntity
}

extension WalkResultEntity {
    
    static func dummy() -> WalkResultEntity {
        return WalkResultEntity(
            weather: .loadingDummy(),
            tracking: .dummy()
        )
    }
}
