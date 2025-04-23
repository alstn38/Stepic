//
//  AppDelegate.swift
//  Stepic
//
//  Created by 강민수 on 3/26/25.
//

import UIKit
import FirebaseCore

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        register()
        FirebaseApp.configure()
        WidgetMigrationService.migrateDataToWidgetRealm()
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
        DIContainer.shared.register(WalkRecordStorageService.self, dependency: DefaultWalkRecordStorageService())
        DIContainer.shared.register(ImageFileStorageService.self, dependency: DefaultImageFileStorageService())
        DIContainer.shared.register(WidgetCalendarWritableStorageService.self, dependency: DefaultWidgetCalendarStorageService())
        
        /// Repository
        DIContainer.shared.register(WeatherLocationRepository.self, dependency: DefaultWeatherLocationRepository())
        DIContainer.shared.register(WalkRecordRepository.self, dependency: DefaultWalkRecordRepository())
        
        /// Manager
        DIContainer.shared.register(LocationPermissionManager.self, dependency: DefaultLocationPermissionManager())
        DIContainer.shared.register(WalkTrackerManager.self, dependency: DefaultWalkTrackerManager())
    }
}
