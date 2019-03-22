//
//  NotificationCenterObserver.swift
//  RoverCampaignsData
//
//  Created by Andrew Clunis on 2019-03-12.
//  Copyright © 2019 Rover Labs Inc. All rights reserved.
//

import Foundation
import os

/// Responsible for listening to specially crafted events emitted on the iOS Notification Center (an event bus built into iOS) so that affilianted modules that are not directly linked against RoverCampaigns (and thus do not have access to its types) are still able to track events.
public class NotificationCenterObserver {
    let eventQueue: EventQueue
    var notificationCenterObserverChit: NSObjectProtocol?
    
    public init(
        eventQueue: EventQueue
    ) {
        self.eventQueue = eventQueue
    }
    
    public func startListening() {
        if notificationCenterObserverChit != nil {
            return
        }
        
        // broadcast to all globally broadcast Notification events on the Notification Center, because we want to filter them by the prefix on their name.
        self.notificationCenterObserverChit = NotificationCenter.default.addObserver(forName: nil, object: nil, queue: nil) { [weak self] notification in
            guard notification.name.rawValue.starts(with: NotificationCenterObserver.roverEventNamePrefix) else {
                return
            }
            
            let camelCaseEventName = notification.name.rawValue.dropFirst(NotificationCenterObserver.roverEventNamePrefix.count)
            let namespace = "rover"
            
            let attributes: Attributes?
            if let attributesHash = notification.userInfo as? [String: Any] {
                attributes = Attributes(rawValue: attributesHash)
            } else {
                attributes = nil
            }
            
            // now to transform the name:
            let name = camelCaseEventName.humanize()
            
            let eventInfo = EventInfo(
                name: name,
                namespace: namespace,
                attributes: attributes,
                timestamp: Date()
            )
            self?.eventQueue.addEvent(eventInfo)
        }
    }
    
    private static let roverEventNamePrefix = "io.rover."
}

extension String.SubSequence {
    /// Convert "CamelCase" to "Camel Case".
    func humanize() -> String {
        return unicodeScalars.reduce("") {
            if CharacterSet.uppercaseLetters.contains($1) {
                return ($0 + " " + String($1))
            }
            else {
                return $0 + String($1)
            }
        }.trimmingCharacters(in: CharacterSet.whitespaces)
    }
}
