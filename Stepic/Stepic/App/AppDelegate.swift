//
//  AppDelegate.swift
//  Stepic
//
//  Created by 강민수 on 3/26/25.
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        register()
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) { }
}

// MARK: - DIContainer
extension AppDelegate {
    
    private func register() {
        /// Service
        DIContainer.shared.register(WeatherService.self, dependency: DefaultWeatherService())
        DIContainer.shared.register(LocationService.self, dependency: DefaultLocationService())
        DIContainer.shared.register(GeocoderService.self, dependency: DefaultGeocoderService())
        
        
        /// Repository
        DIContainer.shared.register(WeatherLocationRepository.self, dependency: DefaultWeatherLocationRepository())
        
        /// Manager
        DIContainer.shared.register(LocationPermissionManager.self, dependency: DefaultLocationPermissionManager())
        DIContainer.shared.register(WalkTrackerManager.self, dependency: DefaultWalkTrackerManager())
    }
}
