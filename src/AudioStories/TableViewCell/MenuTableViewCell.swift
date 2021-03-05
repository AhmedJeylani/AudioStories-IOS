//
//  MenuTableViewCell.swift
//  AudioStories
//
//  Created by Ahmed Jeylani on 15/03/2020.
//  Copyright © 2020 Jeylani Technologies. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
