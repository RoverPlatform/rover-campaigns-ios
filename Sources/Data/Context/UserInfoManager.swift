//
//  UserInfoManager.swift
//  RoverData
//
//  Created by Sean Rucker on 2018-09-29.
//  Copyright © 2018 Rover Labs Inc. All rights reserved.
//

#if !COCOAPODS
import RoverFoundation
#endif

public protocol UserInfoManager {
    var currentUserInfo: Attributes { get }
    func updateUserInfo(block: (inout Attributes) -> Void)
    func clearUserInfo()
    func addTag(_ tag: String, expiresIn: TimeInterval?)
    func removeTag(_ tag: String)
}
