//
//  RoverCampaigns.swift
//  RoverFoundation
//
//  Created by Sean Rucker on 2017-03-31.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation
import os.log

public class RoverCampaigns {
    static var sharedInstance: RoverCampaigns?
    
    public static var shared: Resolver? {
        return sharedInstance
    }
    
    public static func initialize(assemblers: [Assembler]) {
        guard sharedInstance == nil else {
            os_log("Rover already initialized", log: .general, type: .default)
            return
        }
        
        let roverCampaigns = RoverCampaigns()
        
        assemblers.forEach { $0.assemble(container: roverCampaigns) }
        assemblers.forEach { $0.containerDidAssemble(resolver: roverCampaigns) }
        
        if !Thread.isMainThread {
            os_log("Rover must be initialized on the main thread", log: .general, type: .default)
        }
        
        sharedInstance = roverCampaigns
    }
    
    public static func deinitialize() {
        sharedInstance = nil
    }
    
    var services = [ServiceKey: Any]()
}

// MARK: Container

extension RoverCampaigns: Container {
    public func set<Service>(entry: ServiceEntry<Service>, for key: ServiceKey) {
        services[key] = entry
    }
}

// MARK: Resolver

extension RoverCampaigns: Resolver {
    public func entry<Service>(for key: ServiceKey) -> ServiceEntry<Service>? {
        return services[key] as? ServiceEntry<Service>
    }
}
