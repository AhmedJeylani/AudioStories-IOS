//
//  CustomRoundUIButton.swift
//  AudioStories
//
//  Created by Ahmed Jeylani on 27/04/2020.
//  Copyright © 2020 Jeylani Technologies. All rights reserved.
//

import UIKit

class CustomRoundUIButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    func setupButton() {
        layer.cornerRadius = frame.size.width / 2
        layer.masksToBounds = true
    }
}
