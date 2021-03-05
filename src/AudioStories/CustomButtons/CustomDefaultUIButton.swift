//
//  CustomDefaultUIButton.swift
//  AudioStories
//
//  Created by Ahmed Jeylani on 27/04/2020.
//  Copyright © 2020 Jeylani Technologies. All rights reserved.
//

import UIKit

class CustomDefaultUIButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    func setupButton() {
        setTitleColor(.white, for: .normal)
        backgroundColor = UIColor(named:"accent")
        
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        layer.cornerRadius = 10
        layer.borderWidth = 0
    }

}
