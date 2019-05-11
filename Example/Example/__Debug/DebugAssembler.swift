//
//  DebugAssembler.swift
//  Example
//
//  Created by Sean Rucker on 2019-05-10.
//  Copyright © 2019 Rover Labs Inc. All rights reserved.
//

import RoverKit
import UIKit

class DebugAssembler: Assembler {
    func assemble(container: Container) {
        container.register(UIViewController.self, name: "notificationCenter") { resolver in
            let presentWebsiteActionProvider: NotificationCenterViewController.ActionProvider = { [weak resolver] url in
                resolver?.resolve(Action.self, name: "presentWebsite", arguments: url)
            }
            
            return DebugNotificationCenterViewController(
                dispatcher: resolver.resolve(Dispatcher.self)!,
                eventQueue: resolver.resolve(EventQueue.self)!,
                imageStore: resolver.resolve(ImageStore.self)!,
                notificationStore: resolver.resolve(NotificationStore.self)!,
                router: resolver.resolve(Router.self)!,
                sessionController: resolver.resolve(SessionController.self)!,
                syncCoordinator: resolver.resolve(SyncCoordinator.self)!,
                presentWebsiteActionProvider: presentWebsiteActionProvider
            )
        }
    }
}
