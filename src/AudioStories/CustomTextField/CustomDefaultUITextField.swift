//
//  CustomDefaultUITextField.swift
//  AudioStories
//
//  Created by Ahmed Jeylani on 27/04/2020.
//  Copyright © 2020 Jeylani Technologies. All rights reserved.
//

import UIKit

class CustomDefaultUITextField: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTextField()
    }
    
    private func setupTextField() {
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
        leftView = paddingView
        leftViewMode = .always
        rightView = paddingView
        backgroundColor = UIColor(named: "primaryItemBackgroundColor")
        textColor = UIColor(named: "textFieldPrimaryColor")
        tintColor = UIColor(named: "accent")
    }

}
