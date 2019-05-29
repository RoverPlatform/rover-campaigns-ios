//
//  ExperiencesAssembler.swift
//  RoverExperiences
//
//  Created by Sean Rucker on 2018-05-04.
//  Copyright © 2018 Rover Labs Inc. All rights reserved.
//

import Rover
import UIKit

public struct ExperiencesAssembler: Assembler {
    public init() { }
    
    public func assemble(container: Container) {
        
        // MARK: Action (presentExperience)
        
        container.register(Action.self, name: "presentExperience", scope: .transient) { (resolver, id: String, campaignID: String?) in
            let viewControllerToPresent = resolver.resolve(UIViewController.self, name: "experience", arguments: id, campaignID)!
            return resolver.resolve(Action.self, name: "presentView", arguments: viewControllerToPresent)!
        }
        
        container.register(Action.self, name: "presentExperience", scope: .transient) { (resolver, universalLink: URL, campaignID: String?) in
            let viewControllerToPresent = resolver.resolve(UIViewController.self, name: "experience", arguments: universalLink, campaignID)!
            return resolver.resolve(Action.self, name: "presentView", arguments: viewControllerToPresent)!
        }
        
        // MARK: RouteHandler (experience)
        
        container.register(RouteHandler.self, name: "experience") { resolver in            
            let idActionProvider: (String, String?) -> Action? = { [weak resolver] id, campaignID in
                resolver?.resolve(Action.self, name: "presentExperience", arguments: id, campaignID)
            }
                
            let universalLinkActionProvider: (URL, String?) -> Action? = { [weak resolver] universalLink, campaignID in
                resolver?.resolve(Action.self, name: "presentExperience", arguments: universalLink, campaignID)
            }
            
            return ExperienceRouteHandler(
                idActionProvider: idActionProvider,
                universalLinkActionProvider: universalLinkActionProvider
            )
        }
        
        // MARK: RoverObserver
        
        container.register(RoverObserver.self) { resolver in
            RoverObserver(eventQueue: resolver.resolve(EventQueue.self)!)
        }
        
        // MARK: UIViewController (experience)
        
        container.register(UIViewController.self, name: "experience", scope: .transient) { (resolver, id: String, campaignID: String?) in
            let viewController = RoverViewController()
            viewController.loadExperience(id: id, campaignID: campaignID)
            return viewController
        }
        
        container.register(UIViewController.self, name: "experience", scope: .transient) { (resolver, universalLink: URL, campaignID: String?) in
            let viewController = RoverViewController()
            viewController.loadExperience(universalLink: universalLink, campaignID: campaignID)
            return viewController
        }
    }
    
    public func containerDidAssemble(resolver: Resolver) {
        if let router = resolver.resolve(Router.self) {
            let handler = resolver.resolve(RouteHandler.self, name: "experience")!
            router.addHandler(handler)
        }
        
        resolver.resolve(RoverObserver.self)?.enable()
        
        // Pass the accountToken set on the DataAssembler to the Rover SDK.
        Rover.accountToken = resolver.resolve(HTTPClient.self)?.accountToken
    }
}
