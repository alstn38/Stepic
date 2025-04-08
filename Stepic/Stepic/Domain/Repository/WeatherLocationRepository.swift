//
//  WeatherLocationRepository.swift
//  Stepic
//
//  Created by 강민수 on 4/1/25.
//

import Foundation

import CoreLocation
import RxSwift

protocol WeatherLocationRepository {
    func fetchCurrentWeatherLocationInfo() async throws -> WeatherLocationEntity
    func getCurrentLocation() async throws -> CLLocation
}
