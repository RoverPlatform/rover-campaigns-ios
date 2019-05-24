//
//  ExperienceRouteHandler.swift
//  RoverExperiences
//
//  Created by Sean Rucker on 2018-06-19.
//  Copyright © 2018 Rover Labs Inc. All rights reserved.
//

import Foundation

class ExperienceRouteHandler: RouteHandler {
    let idActionProvider: (String, String?) -> Action?
    let universalLinkActionProvider: (URL, String?) -> Action?
    
    init(idActionProvider: @escaping (String, String?) -> Action?, universalLinkActionProvider: @escaping (URL, String?) -> Action?) {
        self.idActionProvider = idActionProvider
        self.universalLinkActionProvider = universalLinkActionProvider
    }
    
    func deepLinkAction(url: URL) -> Action? {
        guard let host = url.host else {
            return nil
        }
        
        if host != "presentExperience" {
            return nil
        }
        
        guard let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems else {
            return nil
        }
        
        guard let experienceID = queryItems.first(where: { $0.name == "experienceID" || $0.name == "id" })?.value else {
            return nil
        }

        let campaignID = queryItems.first(where: { $0.name == "campaignID" })?.value
        return idActionProvider(experienceID, campaignID)
    }
    
    func universalLinkAction(url: URL) -> Action? {
        let campaignID: String?
        if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems {
            campaignID = queryItems.first(where: { $0.name == "campaignID" })?.value
        } else {
            campaignID = nil
        }
        
        return universalLinkActionProvider(url, campaignID)
    }
}
