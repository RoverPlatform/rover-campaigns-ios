//
//  RoverObserver.swift
//  RoverExperiences
//
//  Created by Andrew Clunis on 2019-03-12.
//  Copyright © 2019 Rover Labs Inc. All rights reserved.
//

import Foundation
import os
import Rover

/// Observes notifications posted by the Rover SDK on the default `NotificationCenter` and converts them into events
/// added to the `EventQueue`.
public class RoverObserver {
    private let eventQueue: EventQueue
    private var observers: [NSObjectProtocol] = []
    
    public init(eventQueue: EventQueue) {
        self.eventQueue = eventQueue
    }
    
    deinit {
        disable()
    }
    
    public func enable() {
        guard observers.isEmpty else {
            return
        }
        
        observers = [
            NotificationCenter.default.addObserver(
                forName: ExperienceViewController.experiencePresentedNotification,
                object: nil,
                queue: nil,
                using: { [weak self] notification in
                    self?.trackExperiencePresented(userInfo: notification.userInfo)
                }
            ),
            NotificationCenter.default.addObserver(
                forName: ExperienceViewController.experienceDismissedNotification,
                object: nil,
                queue: nil,
                using: { [weak self] notification in
                    self?.trackExperienceDismissed(userInfo: notification.userInfo)
                }
            ),
            NotificationCenter.default.addObserver(
                forName: ExperienceViewController.experienceViewedNotification,
                object: nil,
                queue: nil,
                using: { [weak self] notification in
                    self?.trackExperienceViewed(userInfo: notification.userInfo)
                }
            ),
            NotificationCenter.default.addObserver(
                forName: ScreenViewController.screenPresentedNotification,
                object: nil,
                queue: nil,
                using: { [weak self] notification in
                    self?.trackScreenPresented(userInfo: notification.userInfo)
                }
            ),
            NotificationCenter.default.addObserver(
                forName: ScreenViewController.screenDismissedNotification,
                object: nil,
                queue: nil,
                using: { [weak self] notification in
                    self?.trackScreenDismissed(userInfo: notification.userInfo)
                }
            ),
            NotificationCenter.default.addObserver(
                forName: ScreenViewController.screenViewedNotification,
                object: nil,
                queue: nil,
                using: { [weak self] notification in
                    self?.trackScreenViewed(userInfo: notification.userInfo)
                }
            ),
            NotificationCenter.default.addObserver(
                forName: ScreenViewController.blockTappedNotification,
                object: nil,
                queue: nil,
                using: { [weak self] notification in
                    self?.trackBlockTapped(userInfo: notification.userInfo)
                }
            ),
            NotificationCenter.default.addObserver(
                forName: ScreenViewController.pollAnsweredNotification,
                object: nil,
                queue: nil,
                using: { [weak self] notification in
                    self?.trackPollAnswered(userInfo: notification.userInfo)
            })
        ]
    }
    
    public func disable() {
        observers.forEach(NotificationCenter.default.removeObserver)
        observers = []
    }
    
    private func trackExperiencePresented(userInfo: [AnyHashable: Any]?) {
        guard let userInfo = userInfo,
            let experience = userInfo[ExperienceViewController.experienceUserInfoKey] as? Experience else {
            return
        }
        
        let attributes: Attributes = [
            "experience": [
                "id": experience.id,
                "name": experience.name,
                "keys": experience.keys,
                "tags": experience.tags
            ]
        ]
        
        if let campaignID = userInfo[ExperienceViewController.campaignIDUserInfoKey] as? String {
            (attributes["experience"] as? Attributes)?["campaignID"] = campaignID
        }
        
        let eventInfo = EventInfo(
            name: "Experience Presented",
            namespace: "rover",
            attributes: attributes
        )
        
        eventQueue.addEvent(eventInfo)
    }
    
    private func trackExperienceDismissed(userInfo: [AnyHashable: Any]?) {
        guard let userInfo = userInfo,
            let experience = userInfo[ExperienceViewController.experienceUserInfoKey] as? Experience else {
                return
        }
        
        let attributes: Attributes = [
            "experience": [
                "id": experience.id,
                "name": experience.name,
                "keys": experience.keys,
                "tags": experience.tags
            ]
        ]
        
        if let campaignID = userInfo[ExperienceViewController.campaignIDUserInfoKey] as? String {
            (attributes["experience"] as? Attributes)?["campaignID"] = campaignID
        }
        
        let eventInfo = EventInfo(
            name: "Experience Dismissed",
            namespace: "rover",
            attributes: attributes
        )
        
        eventQueue.addEvent(eventInfo)
    }
    
    private func trackExperienceViewed(userInfo: [AnyHashable: Any]?) {
        guard let userInfo = userInfo,
            let experience = userInfo[ExperienceViewController.experienceUserInfoKey] as? Experience,
            let duration = userInfo[ExperienceViewController.durationUserInfoKey] as? Double else {
                return
        }
        
        let attributes: Attributes = [
            "experience": [
                "id": experience.id,
                "name": experience.name,
                "keys": experience.keys,
                "tags": experience.tags
            ],
            "duration": duration
        ]
        
        if let campaignID = userInfo[ExperienceViewController.campaignIDUserInfoKey] as? String {
            (attributes["experience"] as? Attributes)?["campaignID"] = campaignID
        }
        
        let eventInfo = EventInfo(
            name: "Experience Viewed",
            namespace: "rover",
            attributes: attributes
        )
        
        eventQueue.addEvent(eventInfo)
    }
    
    private func trackScreenPresented(userInfo: [AnyHashable: Any]?) {
        guard let userInfo = userInfo,
            let experience = userInfo[ScreenViewController.experienceUserInfoKey] as? Experience,
            let screen = userInfo[ScreenViewController.screenUserInfoKey] as? Screen else {
                return
        }
        
        let attributes: Attributes = [
            "experience": [
                "id": experience.id,
                "name": experience.name,
                "keys": experience.keys,
                "tags": experience.tags
            ],
            "screen": [
                "id": screen.id,
                "name": screen.name,
                "keys": screen.keys,
                "tags": screen.tags
            ]
        ]
        
        if let campaignID = userInfo[ScreenViewController.campaignIDUserInfoKey] as? String {
            (attributes["experience"] as? Attributes)?["campaignID"] = campaignID
        }
        
        let eventInfo = EventInfo(
            name: "Screen Presented",
            namespace: "rover",
            attributes: attributes
        )
        
        eventQueue.addEvent(eventInfo)
    }
    
    private func trackScreenDismissed(userInfo: [AnyHashable: Any]?) {
        guard let userInfo = userInfo,
            let experience = userInfo[ScreenViewController.experienceUserInfoKey] as? Experience,
            let screen = userInfo[ScreenViewController.screenUserInfoKey] as? Screen else {
                return
        }
        
        let attributes: Attributes = [
            "experience": [
                "id": experience.id,
                "name": experience.name,
                "keys": experience.keys,
                "tags": experience.tags
            ],
            "screen": [
                "id": screen.id,
                "name": screen.name,
                "keys": screen.keys,
                "tags": screen.tags
            ]
        ]
        
        if let campaignID = userInfo[ScreenViewController.campaignIDUserInfoKey] as? String {
            (attributes["experience"] as? Attributes)?["campaignID"] = campaignID
        }
        
        let eventInfo = EventInfo(
            name: "Screen Dismissed",
            namespace: "rover",
            attributes: attributes
        )
        
        eventQueue.addEvent(eventInfo)
    }
    
    private func trackScreenViewed(userInfo: [AnyHashable: Any]?) {
        guard let userInfo = userInfo,
            let experience = userInfo[ScreenViewController.experienceUserInfoKey] as? Experience,
            let screen = userInfo[ScreenViewController.screenUserInfoKey] as? Screen,
            let duration = userInfo[ScreenViewController.durationUserInfoKey] as? Double else {
                return
        }
        
        let attributes: Attributes = [
            "experience": [
                "id": experience.id,
                "name": experience.name,
                "keys": experience.keys,
                "tags": experience.tags
            ],
            "screen": [
                "id": screen.id,
                "name": screen.name,
                "keys": screen.keys,
                "tags": screen.tags
            ],
            "duration": duration
        ]
        
        if let campaignID = userInfo[ScreenViewController.campaignIDUserInfoKey] as? String {
            (attributes["experience"] as? Attributes)?["campaignID"] = campaignID
        }
        
        let eventInfo = EventInfo(
            name: "Screen Viewed",
            namespace: "rover",
            attributes: attributes
        )
        
        eventQueue.addEvent(eventInfo)
    }
    
    private func trackBlockTapped(userInfo: [AnyHashable: Any]?) {
        guard let userInfo = userInfo,
            let experience = userInfo[ScreenViewController.experienceUserInfoKey] as? Experience,
            let screen = userInfo[ScreenViewController.screenUserInfoKey] as? Screen,
            let block = userInfo[ScreenViewController.blockUserInfoKey] as? Block else {
                return
        }
        
        let attributes: Attributes = [
            "experience": [
                "id": experience.id,
                "name": experience.name,
                "keys": experience.keys,
                "tags": experience.tags
            ],
            "screen": [
                "id": screen.id,
                "name": screen.name,
                "keys": screen.keys,
                "tags": screen.tags
            ],
            "block": [
                "id": block.id,
                "name": block.name,
                "keys": block.keys,
                "tags": block.tags
            ]
        ]
        
        if let campaignID = userInfo[ScreenViewController.campaignIDUserInfoKey] as? String {
            (attributes["experience"] as? Attributes)?["campaignID"] = campaignID
        }
        
        let eventInfo = EventInfo(
            name: "Block Tapped",
            namespace: "rover",
            attributes: attributes
        )
        
        eventQueue.addEvent(eventInfo)
    }
    
    private func trackPollAnswered(userInfo: [AnyHashable: Any]?) {
        guard let userInfo = userInfo,
            let experience = userInfo[ScreenViewController.experienceUserInfoKey] as? Experience,
            let screen = userInfo[ScreenViewController.screenUserInfoKey] as? Screen,
            let block = userInfo[ScreenViewController.blockUserInfoKey] as? Block,
            let pollOption = userInfo[ScreenViewController.optionUserInfoKey] as? PollOption
        else {
                return
        }
        
        var optionHash = [
            "id": pollOption.id,
            "text": pollOption.text.rawValue
        ]
        
        if let pollImage = (pollOption as? ImagePollBlock.ImagePoll.Option)?.image {
            optionHash["poll"] = pollImage.url.absoluteString
        }
        
        let attributes: Attributes = [
            "experience": [
                "id": experience.id,
                "name": experience.name,
                "keys": experience.keys,
                "tags": experience.tags
            ],
            "screen": [
                "id": screen.id,
                "name": screen.name,
                "keys": screen.keys,
                "tags": screen.tags
            ],
            "block": [
                "id": block.id,
                "name": block.name,
                "keys": block.keys,
                "tags": block.tags
            ],
            "option": optionHash
        ]
        
        if let campaignID = userInfo[ScreenViewController.campaignIDUserInfoKey] as? String {
            (attributes["experience"] as? Attributes)?["campaignID"] = campaignID
        }
        
        let eventInfo = EventInfo(
            name: "Poll Answered",
            namespace: "rover",
            attributes: attributes
        )
        
        eventQueue.addEvent(eventInfo)
    }
}
