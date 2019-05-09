//
//  AppDelegate.swift
//  Example
//
//  Created by Sean Rucker on 2019-04-30.
//  Copyright © 2019 Rover Labs Inc. All rights reserved.
//

import Rover
import RoverAdSupport
import RoverBluetooth
import RoverData
import RoverDebug
import RoverFoundation
import RoverLocation
import RoverNotifications
import RoverTelephony
import RoverTicketmaster
import RoverUI

import CoreLocation
import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var locationManager = CLLocationManager()
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Pass your account token from the Rover Settings app to the Rover SDK.
        Rover.accountToken = "<YOUR_SDK_TOKEN>"
        
        // Initialize the RoverCampaigns SDK with all modules.
        RoverCampaigns.initialize(assemblers: [
            AdSupportAssembler(),
            BluetoothAssembler(),
            DataAssembler(accountToken: "<YOUR_SDK_TOKEN>"), // The same token used above
            DebugAssembler(),
            FoundationAssembler(),
            LocationAssembler(),
            NotificationsAssembler(appGroup: "group.io.rover.Example"), // Used to share `UserDefaults` data between the main app target and the notification service extension.
            TelephonyAssembler(),
            TicketmasterAssembler(),
            UIAssembler(urlSchemes: ["rv-example"])
        ])
        
        // Sync notifications, beacons and geofences when the app is opened from a terminated state.
        RoverCampaigns.shared?.resolve(SyncCoordinator.self)?.sync {
            // After the first sync call the updateLocation method on the RegionManager to start monitoring for the nearest beacons and geofences.
            RoverCampaigns.shared?.resolve(RegionManager.self)?.updateLocation(manager: self.locationManager)
        }
        
        // Setting the minimum background fetch interval is required for background fetch to work properly.
        application.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        
        // Request access to the user's location, even when the app is in the background. This will present the standard iOS permission prompt to the user.
        locationManager.requestAlwaysAuthorization()
        
        // Assign the app delegate as the location manager’s delegate and start monitoring for significant location changes.
        locationManager.delegate = self
        locationManager.startMonitoringSignificantLocationChanges()
        
        // Register to receive remote notifications via Apple Push Notification service. Make sure this is called EVERY time the application finishes launching.
        application.registerForRemoteNotifications()
        
        // Request permission to display alerts, badge your app's icon and play sounds.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
        
        // Assign the app delegate as the notification manager’s delegate so we can respond when the user taps a notification.
        UNUserNotificationCenter.current().delegate = self
        
        // Set custom info about the current user
        RoverCampaigns.shared?.resolve(UserInfoManager.self)?.updateUserInfo { attributes in
            attributes["foo"] = "bar"
        }
        
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Sync notifications, beacons and geofences when the app is opened while already running in the background.
        RoverCampaigns.shared?.resolve(SyncCoordinator.self)?.sync()
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Sync notifications, beacons and geofences when the app is in the background.
        RoverCampaigns.shared?.resolve(SyncCoordinator.self)?.sync(completionHandler: completionHandler)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Sync notifications, beacons and geofences when the Rover server issues requests a sync via remote push.
        RoverCampaigns.shared?.resolve(SyncCoordinator.self)?.sync(completionHandler: completionHandler)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Handle RoverCampaigns specific deep links. E.g. rv-example://presentNotificationCenter or rv-example://presentSettings.
        if let router = RoverCampaigns.shared?.resolve(Router.self), router.handle(url) {
            return true
        }
        
        // This deep link isn't a RoverCampaigns specific URL. Check if the deep link is intended to launch a Rover
        // experience.
        if url.host == "presentExperience" {
            guard let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems else {
                return false
            }
            
            guard let experienceID = queryItems.first(where: { $0.name == "id" })?.value else {
                return false
            }
            
            let campaignID = queryItems.first(where: { $0.name == "campaignID" })?.value
            let viewController = RoverViewController(experienceID: experienceID, campaignID: campaignID)
            app.present(viewController, animated: true)
            return true

        }
        
        return false
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // The device successfully registered for push notifications. Pass the token to RoverCampaigns.
        RoverCampaigns.shared!.resolve(TokenManager.self)?.setToken(deviceToken)
    }
}

// MARK: CLLocationManagerDelegate

extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Report the user's current location to the RegionManager so it can ensure it is monitoring for the nearest geofences and beacons. This will also track a "Location Updated" event which can be used to deliver location-relevant campaigns.
        RoverCampaigns.shared?.resolve(RegionManager.self)?.updateLocation(manager: manager)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        switch region {
        case let region as CLBeaconRegion:
            // The user entered a monitored beacon region. Start ranging for more accurate beacon detection.
            RoverCampaigns.shared?.resolve(RegionManager.self)?.startRangingBeacons(in: region, manager: manager)
        case let region as CLCircularRegion:
            // The user entered a geofence region. Track a "Geofence Entered" event.
            RoverCampaigns.shared?.resolve(RegionManager.self)?.enterGeofence(region: region)
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        switch region {
        case let region as CLBeaconRegion:
            // The user exited a monitored beacon region. Stop ranging to resume geofence monitoring.
            RoverCampaigns.shared?.resolve(RegionManager.self)?.stopRangingBeacons(in: region, manager: manager)
        case let region as CLCircularRegion:
            // The user exited a geofence region. Track a "Geofence Exited" event.
            RoverCampaigns.shared?.resolve(RegionManager.self)?.exitGeofence(region: region)
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        // The set of nearby beacons changed. Compare to the previous set and track beacon enter/exit events as needed.
        RoverCampaigns.shared?.resolve(RegionManager.self)?.updateNearbyBeacons(beacons, in: region, manager: manager)
    }
}

// MARK: UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // A notification was received while the app was in the foreground. Tell the operating system to display the notification the same way as if the app was in the background.
        completionHandler([.badge, .sound, .alert])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // The user tapped a notification. Pass the response to RoverCampaigns to handle the intended behavior.
        RoverCampaigns.shared?.resolve(NotificationHandler.self)?.handle(response, completionHandler: completionHandler)
    }
}
