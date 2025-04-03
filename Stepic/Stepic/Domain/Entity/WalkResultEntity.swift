//
//  WalkResultEntity.swift
//  Stepic
//
//  Created by 강민수 on 4/3/25.
//

import Foundation

struct WalkResultEntity {
    var photos: [WalkPhotoEntity]
    var weather: WeatherLocationEntity
    var tracking: WalkTrackingEntity
}
