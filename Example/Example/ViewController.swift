//
//  ViewController.swift
//  Example
//
//  Created by Sean Rucker on 2019-04-30.
//  Copyright © 2019 Rover Labs Inc. All rights reserved.
//

import RoverNotifications
import UIKit

class ViewController: UIViewController {
    @IBAction func presentNotificationCenter(_ sender: Any) {
        // Resolve the Rover Notification Center view controller
        guard let notificationCenter = RoverCampaigns.shared?.resolve(UIViewController.self, name: "notificationCenter") else {
            return
        }
        
        present(notificationCenter, animated: true, completion: nil)
    }
}
