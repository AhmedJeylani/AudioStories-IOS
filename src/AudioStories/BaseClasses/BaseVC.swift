//
//  BaseVC.swift
//  AudioStories
//
//  Created by Ahmed Jeylani on 03/05/2020.
//  Copyright © 2020 Jeylani Technologies. All rights reserved.
//

import UIKit

class BaseVC: UIViewController {

    var userInfo = BaseUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userInfo = Cache.GetUserInfo()!
    }
}
