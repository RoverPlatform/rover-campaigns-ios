//
//  TicketmasterManager.swift
//  RoverTicketmaster
//
//  Created by Sean Rucker on 2018-09-29.
//  Copyright © 2018 Rover Labs Inc. All rights reserved.
//

import Foundation
import os.log

class TicketmasterManager {
    let userInfoManager: UserInfoManager
    
    struct Member: Codable {
        var id: String
        var email: String?
        var firstName: String?
        
        /// Return the basic UserInfo dictionary for ticketmaster given just the locally known data.
        var userInfo: [String: Any?] {
            return [
                "id": id,
                "email": email,
                "firstName": firstName
            ]
        }
    }
    
    var member = PersistedValue<Member>(storageKey: "io.rover.RoverTicketmaster")
    
    init(userInfoManager: UserInfoManager) {
        self.userInfoManager = userInfoManager
    }
}

// MARK: TicketmasterAuthorizer

extension TicketmasterManager: TicketmasterAuthorizer {
    func setCredentials(accountManagerMemberID: String, hostMemberID: String) {
        if !accountManagerMemberID.isEmpty {
            self.member.value = Member(id: accountManagerMemberID, email: nil, firstName: nil)
        } else if hostMemberID.isEmpty {
            self.member.value = Member(id: hostMemberID, email: nil, firstName: nil)
        } else {
            // neither value was given, treat it as a logout.
            clearCredentials()
        }
    }
    
    func setCredentials(id: String, email: String, firstName: String?) {
        let newMember = Member(id: id, email: email, firstName: firstName)
        self.member.value = newMember
        
        // As a side-effect, set the fields into the `ticketmaster` hash in userInfo so they are immediately available even without a server sync succeeding.
        self.userInfoManager.updateUserInfo {
            if let existingTicketmasterUserInfo = $0.rawValue["ticketmaster"] as? [String: Any?] {
                // ticketmaster already exists, just clobber the three fields:
                $0.rawValue["ticketmaster"] = existingTicketmasterUserInfo.merging(newMember.userInfo) { $1 }
            } else {
                // ticketmaster data does not already exist, so set it:
                $0.rawValue["ticketmaster"] = newMember.userInfo
            }
        }
    }
    
    func clearCredentials() {
        self.member.value = nil
        self.userInfoManager.updateUserInfo { attributes in
            attributes.rawValue["ticketmaster"] = nil
        }
    }
}

// MARK: SyncParticipant

extension SyncQuery {
    static let ticketmaster = SyncQuery(
        name: "ticketmasterProfile",
        body: """
            attributes
            """,
        arguments: [
            SyncQuery.Argument(name: "id", type: "String")
        ],
        fragments: []
    )
}

extension TicketmasterManager: SyncParticipant {
    func initialRequest() -> SyncRequest? {
        guard let member = self.member.value else {
            return nil
        }
        
        return SyncRequest(
            query: .ticketmaster,
            values: [
                "id": member.id,
            ]
        )
    }
    
    struct Response: Decodable {
        struct Data: Decodable {
            struct Profile: Decodable {
                var attributes: Attributes?
            }
            
            var ticketmasterProfile: Profile
        }
        
        var data: Data
    }
    
    func saveResponse(_ data: Data) -> SyncResult {
        let response: Response
        do {
            response = try JSONDecoder.default.decode(Response.self, from: data)
        } catch {
            os_log("Failed to decode response: %@", log: .sync, type: .error, error.localizedDescription)
            return .failed
        }
        
        guard let attributes = response.data.ticketmasterProfile.attributes else {
            return .noData
        }
        
        let localAttributes: [String: Any?] = member.value?.userInfo ?? [String: Any?]()
        
        // Set the `ticketmaster` field on userInfo, but clobber the id, email, and firstName fields that might have come back from the server with our local values.
        self.userInfoManager.updateUserInfo {
            $0.rawValue["ticketmaster"] = localAttributes.merging(attributes.rawValue) { (localValue, _) in localValue }
        }
        
        return .newData(nextRequest: nil)
    }
}
