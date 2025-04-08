//
//  DefaultWeatherLocationRepository.swift
//  Stepic
//
//  Created by 강민수 on 4/1/25.
//

import Foundation

import CoreLocation
import RxSwift

final class DefaultWeatherLocationRepository: WeatherLocationRepository {
    
    private let locationService: LocationService
    private let geocodingService: GeocoderService
    private let weatherService: WeatherService
    
    init(
        locationService: LocationService = DIContainer.shared.resolve(LocationService.self),
        geocodingService: GeocoderService = DIContainer.shared.resolve(GeocoderService.self),
        weatherService: WeatherService = DIContainer.shared.resolve(WeatherService.self)
    ) {
        self.locationService = locationService
        self.geocodingService = geocodingService
        self.weatherService = weatherService
    }
    
    /// 현재 위치 기반 주소 및 날씨 정보를 모두 가져오는 메서드
    func fetchCurrentWeatherLocationInfo() async throws -> WeatherLocationEntity {
        let location = try await locationService.getCurrentLocation()

        async let addressDTO = geocodingService.reverseGeocode(location: location)
        async let weatherDTO = weatherService.fetchCurrentWeather(location: location)

        let (address, weather) = try await (addressDTO, weatherDTO)

        return WeatherLocationEntity(
            city: address.city,
            district: address.district,
            street: address.street,
            symbolName: weather.symbolName,
            description: weather.description,
            temperature: String(format: "%.0f", weather.temperature) + "\(weather.unitSymbol)"
        )
    }
    
    /// 위치를 한번만 요청하고 위치 연결을 해제하는 메서드
    func getCurrentLocation() async throws -> CLLocation {
        return try await locationService.getCurrentLocation()
    }
}
