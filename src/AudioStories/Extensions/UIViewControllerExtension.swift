//
//  UIViewControllerExtensions.swift
//  AudioStories
//
//  Created by Ahmed Jeylani on 02/04/2020.
//  Copyright © 2020 Jeylani Technologies. All rights reserved.
//

import UIKit

// Put this piece of code anywhere you like
extension UIViewController : UITextFieldDelegate {
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
