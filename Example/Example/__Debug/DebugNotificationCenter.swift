//
//  DebugNotificationCenter.swift
//  Example
//
//  Created by Sean Rucker on 2019-05-10.
//  Copyright © 2019 Rover Labs Inc. All rights reserved.
//

import Foundation
import RoverFoundation
import RoverNotifications
import Rover

class DebugNotificationCenterViewController: NotificationCenterViewController {
    open override func filterNotifications() -> [RoverNotifications.Notification] {
        return super.filterNotifications().map { notification in
            guard case let .openURL(url) = notification.tapBehavior else {
                return notification
            }
            
            guard let scheme = url.scheme else {
                return notification
            }
            
            guard scheme.starts(with: "rv-") else {
                return notification
            }
            
            guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                return notification
            }
            
            components.scheme = "rv-example"
            guard let nextURL = components.url else {
                return notification
            }
            
            var nextNotification = notification
            nextNotification.tapBehavior = .openURL(url: nextURL)
            return nextNotification
        }
    }
}

