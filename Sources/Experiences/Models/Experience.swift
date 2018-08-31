//
//  Experience.swift
//  RoverExperiences
//
//  Created by Sean Rucker on 2017-10-19.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

public struct Experience {
    public var id: ID
    public var campaignID: ID?
    public var homeScreen: Screen
    public var screens: [Screen]
    public var keys: [String: String]
    public var tags: [String]
    
    public init(id: ID, campaignID: ID?, homeScreen: Screen, screens: [Screen], keys: [String: String], tags: [String]) {
        self.id = id
        self.campaignID = campaignID
        self.homeScreen = homeScreen
        self.screens = screens
        self.keys = keys
        self.tags = tags
    }
}

// MARK: Decodable

extension Experience: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case campaignID
        case homeScreenID
        case screens
        case keys
        case tags
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(ID.self, forKey: .id)
        campaignID = try container.decode(ID?.self, forKey: .campaignID)
        screens = try container.decode([Screen].self, forKey: .screens)
        keys = try container.decode([String: String].self, forKey: .keys)
        tags = try container.decode([String].self, forKey: .tags)
        
        let homeScreenID = try container.decode(ID.self, forKey: .homeScreenID)
        
        guard let homeScreen = screens.first(where: { $0.id == homeScreenID }) else {
            throw DecodingError.dataCorruptedError(forKey: .homeScreenID, in: container, debugDescription: "No screen found with homeScreenID \(homeScreenID)")
        }
        
        self.homeScreen = homeScreen
    }
}

// MARK: AttributeRepresentable

extension Experience: AttributeRepresentable {
    public var attributeValue: AttributeValue {
        var attributes: Attributes = [
            "id": id,
            "tags": tags
        ]
        
        if let campaignID = campaignID {
            attributes["campaignID"] = campaignID
        }
        
        return .object(attributes)
    }
}
