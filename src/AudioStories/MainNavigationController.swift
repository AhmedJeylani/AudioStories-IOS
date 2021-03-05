//
//  MainNavigationController.swift
//  AudioStories
//
//  Created by Ahmed Jeylani on 15/03/2020.
//  Copyright © 2020 Jeylani Technologies. All rights reserved.
//

import UIKit
import Firebase

class MainNavigatonController : UINavigationController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "primaryTitleBarColor")
        
        let userDefaults = UserDefaults.standard
        
        if (!userDefaults.bool(forKey: "hasRunBefore")) {
            print("The app is launching for the first time. Setting UserDefaults...")

            Utilities.signOut(auth: Auth.auth())
            
            // Update the flag indicator
            userDefaults.setValue(true, forKey: "hasRunBefore")
            userDefaults.synchronize() // This forces the app to update userDefaults
        } else {
            print("The app has been launched before. Loading UserDefaults...")
        }
        
        let fAuth = Auth.auth()
        navigationBar.isHidden = true
        
        if let fUser = fAuth.currentUser {
            Utilities.getUserDetails(user: fUser, navigationController: self)
        } else {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyBoard.instantiateViewController(withIdentifier: "loginVC") as! LoginVC
            self.viewControllers = [loginVC]
        }
    }
    
    @objc func showLoginVC () {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyBoard.instantiateViewController(withIdentifier: "loginVC") as! LoginVC
        self.present(loginVC, animated: false, completion: .none)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
