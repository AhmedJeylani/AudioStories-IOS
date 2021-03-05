//
//  UITextFieldExtension.swift
//  AudioStories
//
//  Created by Ahmed Jeylani on 07/05/2020.
//  Copyright © 2020 Jeylani Technologies. All rights reserved.
//

import UIKit

extension UITextField{
    
    func setInvalid() {
        self.layer.borderColor = UIColor.systemRed.cgColor
        self.layer.borderWidth = 2
    }
    
    func setValid() {
        self.layer.borderWidth = 0
    }
    
}
