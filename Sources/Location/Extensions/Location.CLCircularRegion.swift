//
//  CLCircularRegion.swift
//  RoverCampaignsLocation
//
//  Created by Sean Rucker on 2018-08-21.
//  Copyright © 2018 Rover Labs Inc. All rights reserved.
//

import CoreLocation

extension CLCircularRegion {
    public var attributes: Attributes {
        return [
            "center": [
                center.latitude,
                center.longitude
            ],
            "radius": radius
        ]
    }
}