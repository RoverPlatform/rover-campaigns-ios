//
//  ExperienceConversionsManager.swift
//  RoverExperiences
//
//  Created by Chris Recalis on 2020-06-25.
//  Copyright © 2020 Rover Labs Inc. All rights reserved.
//
import Foundation
import os.log
#if !COCOAPODS
import RoverFoundation
import RoverData
#endif

public class ExperienceConversionsManager: ConversionsContextProvider {
    private let persistedConversions = PersistedValue<Set<Tag>>(storageKey: "io.rover.RoverExperiences.conversions")
    public var conversions: [String]? {
        let result = self.persistedConversions.value?.filter{ $0.expiresAt > Date() }.map{ $0.rawValue }
        os_log("ExperienceConversionsManager(%@) yielding persisted conversions value: %@ (raw stored data is %@)", ObjectIdentifier(self).debugDescription, result?.description ?? "nil", self.persistedConversions.value?.description ?? "nil")
        return result
    }
    
    func track(_ tag: String, _ expiresIn: TimeInterval) {
        var result = (self.persistedConversions.value ?? []).filter { $0.expiresAt > Date() }
        result.update(with: Tag(
            rawValue: tag,
            expiresAt: Date().addingTimeInterval(expiresIn)
        ))
        os_log("Conversions updated from %@ to %@", self.persistedConversions.value?.description ?? "nil", result.description)
        self.persistedConversions.value = result
        os_log("Conversions value after update is: %@", self.persistedConversions.value?.description ?? "nil")
    }
}

private struct Tag: Codable, Equatable, Hashable {
    public static func == (lhs: Tag, rhs: Tag) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
    
    public var rawValue: String
    public var expiresAt: Date = Date()
}
