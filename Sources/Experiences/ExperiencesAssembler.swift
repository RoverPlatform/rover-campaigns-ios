//
//  ExperiencesAssembler.swift
//  RoverExperiences
//
//  Created by Sean Rucker on 2018-05-04.
//  Copyright © 2018 Rover Labs Inc. All rights reserved.
//

import UIKit

public struct ExperiencesAssembler: Assembler {
    public init() { }
    
    public func assemble(container: Container) {
        
        // MARK: RoverObserver
        
        container.register(RoverObserver.self) { resolver in
            RoverObserver(eventQueue: resolver.resolve(EventQueue.self)!)
        }
    }
    
    public func containerDidAssemble(resolver: Resolver) {
        if let router = resolver.resolve(Router.self) {
            let handler = resolver.resolve(RouteHandler.self, name: "experience")!
            router.addHandler(handler)
        }
        
        resolver.resolve(RoverObserver.self)?.enable()
    }
}
