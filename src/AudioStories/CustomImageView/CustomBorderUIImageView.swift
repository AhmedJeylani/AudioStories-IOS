//
//  CustomBorderUIImageView.swift
//  AudioStories
//
//  Created by Ahmed Jeylani on 02/05/2020.
//  Copyright © 2020 Jeylani Technologies. All rights reserved.
//

import UIKit

class CustomBorderUIImageView: CustomDefaultUIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupImageView()
    }
    
    private func setupImageView() {
        let borderColor = UIColor(named: "borderColor")?.cgColor
        layer.borderWidth = 3
        layer.borderColor = borderColor
    }
    
}
