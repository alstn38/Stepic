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
    
    private let weatherDescriptionMapper: [String: String] = [
        "Mostly clear with scattered clouds" : "Clear",
        "Partly cloudy with occasional showers" : "Cloudy",
        "Overcast with a chance of rain" : "Cloudy",
        "Thunderstorms likely with gusty winds" : "Thunder",
        "Clear and cold with light winds" : "Clear",
        "Scattered showers and thunderstorms" : "Rain",
        "Light snow mixed with rain" : "Sleet",
        "Heavy rain and strong winds" : "Rain",
        "Dense fog with low visibility" : "Fog",
        "Snow showers with thunder" : "Snow",
        "Mix of rain and snow" : "Sleet",
        "대체로 청명함" : "맑음",
        "대체로 맑음" : "맑음",
        "부분적으로 흐림" : "구름",
        "흐리고 가끔 비" : "가끔 비",
        "소나기 및 천둥" : "소나기",
        "강한 바람과 뇌우" : "뇌우",
        "짙은 안개 및 흐림" : "안개",
        "맑고 상쾌하며 약간 흐림" : "맑음",
        "가벼운 눈 또는 진눈깨비" : "눈",
        "비와 눈 혼합" : "눈비"
    ]
    
    /// 현재 날씨 정보를 가져오는 메서드
    /// - Parameters:
    ///   - latitude: 위도
    ///   - longitude: 경도
    /// - Returns: `CurrentWeatherDTO
    func fetchCurrentWeather(location: CLLocation) async throws -> CurrentWeatherDTO {
        
        let weather = try await weatherService.weather(for: location)
        let currentWeather = weather.currentWeather
        let description = currentWeather.condition.description
        
        let symbolName = currentWeather.symbolName
        let conditionDescription = weatherDescriptionMapper[description] ?? description
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
