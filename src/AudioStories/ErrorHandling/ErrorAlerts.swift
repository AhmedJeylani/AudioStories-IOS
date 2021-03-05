//
//  ErrorAlerts.swift
//  AudioStories
//
//  Created by Ahmed Jeylani on 05/04/2020.
//  Copyright © 2020 Jeylani Technologies. All rights reserved.
//

import UIKit

class ErrorAlert {
    
    static func noUserAvailable(error: Error, displayMessage: String, sender: AnyObject) {
        if error.localizedDescription.contains("no user record") {
            Utilities.createAlert(title: "Error Finding User", message: "This email address has not been registered. " + displayMessage, sender: sender)
        } else {
            Utilities.createAlert(title: "Error", message: error.localizedDescription, sender: sender)
        }
    }
}
