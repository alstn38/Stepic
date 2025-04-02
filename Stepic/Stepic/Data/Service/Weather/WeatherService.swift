//
//  WeatherService.swift
//  Stepic
//
//  Created by 강민수 on 4/1/25.
//

import Foundation

import CoreLocation
import WeatherKit

protocol WeatherService {
    func fetchCurrentWeather(location: CLLocation) async throws -> CurrentWeatherDTO
}

final class DefaultWeatherService: WeatherService {
    
    private let weatherService = WeatherKit.WeatherService.shared
    
    /// 현재 날씨 정보를 가져오는 메서드
    /// - Parameters:
    ///   - latitude: 위도
    ///   - longitude: 경도
    /// - Returns: `CurrentWeatherDTO
    func fetchCurrentWeather(location: CLLocation) async throws -> CurrentWeatherDTO {
        
        let weather = try await weatherService.weather(for: location)
        let currentWeather = weather.currentWeather
        
        let symbolName = currentWeather.symbolName
        let conditionDescription = currentWeather.condition.description
        let temperature = currentWeather.temperature.value
        let unitSymbol = currentWeather.temperature.unit.symbol
        
        return CurrentWeatherDTO(
            symbolName: symbolName,
            description: conditionDescription,
            temperature: temperature,
            unitSymbol: unitSymbol
        )
    }
}
