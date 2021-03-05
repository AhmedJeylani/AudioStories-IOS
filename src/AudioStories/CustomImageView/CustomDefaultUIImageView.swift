//
//  CustomDefaultUIImageView.swift
//  AudioStories
//
//  Created by Ahmed Jeylani on 28/04/2020.
//  Copyright © 2020 Jeylani Technologies. All rights reserved.
//

import UIKit

class CustomDefaultUIImageView: UIImageView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupImageView()
    }
    
    private func setupImageView() {
        layer.masksToBounds = true
        layer.cornerRadius = frame.size.width / 2
        layer.borderWidth = 0
    }
}
