//
//  StringExtension.swift
//  AudioStories
//
//  Created by Ahmed Jeylani on 07/05/2020.
//  Copyright © 2020 Jeylani Technologies. All rights reserved.
//

import UIKit

extension String {
    
    enum ValidityType {
        case email
        case password
        case username
    }
    
    enum Regex:String {
        case email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}" // valid email format
        case password = "^(?=.*[A-Za-z])(?=\\S+$).{6,}$" // Password has to be minimum 6 characters
        case username = "\\A\\w{3,18}\\z" // no special characters, only numbers and letters and no whitepaces
    }
    
    func isValid(validityType: ValidityType) -> Bool {
        let format = "SELF MATCHES %@"
        var regex = ""
        
        switch validityType {
        case .email:
            regex = Regex.email.rawValue
            
        case .password:
            regex = Regex.password.rawValue
            
        case .username:
            regex = Regex.username.rawValue
        }
        
        return NSPredicate(format: format, regex).evaluate(with: self)
    }
    
    func matches(_ text: String) -> Bool {
        if self == text {
            return true
        } else {
            return false
        }
    }
    
    func stringByAppendingPathComponent(path: String) -> String {
        let nsSt = self as NSString
        return nsSt.appendingPathComponent(path)
    }
}
