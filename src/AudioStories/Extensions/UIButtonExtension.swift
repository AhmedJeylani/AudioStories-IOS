//
//  UIButtonExtension.swift
//  AudioStories
//
//  Created by Ahmed Jeylani on 07/05/2020.
//  Copyright © 2020 Jeylani Technologies. All rights reserved.
//

import UIKit

extension UIButton {
    
    func enable(title:String?) {
        self.isEnabled = true
        self.backgroundColor = UIConstants.ENABLED_COLOR
        if let changedTitle = title {
            self.setTitle(changedTitle, for: .normal)
        }
    }
    
    func disable(title:String?) {
        self.isEnabled = false
        self.backgroundColor = UIConstants.DISABLED_COLOR
        if let changedTitle = title {
            self.setTitle(changedTitle, for: .normal)
        }
    }
}
