//
//  ContainerVC.swift
//  AudioStories
//
//  Created by Ahmed Jeylani on 03/07/2019.
//  Copyright © 2019 Jeylani Technologies. All rights reserved.
//

import UIKit
import Firebase

class ContainerVC: BaseVC {

    @IBOutlet var containerView: UIView!
    @IBOutlet weak var sideMenuConstraint: NSLayoutConstraint!
    @IBOutlet weak var sideMenu: UIView!
    @IBOutlet weak var eventListView: UIView!
    @IBOutlet weak var blackView: UIView!
    
    var _databaseRef:DatabaseReference?
    var _fAuth:Auth?
    var _firebaseUser:User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isToolbarHidden = true // This is the bottom bar
        self.navigationController?.navigationBar.isHidden = true
        
        // This gets the response from the menu button in the Event List view controller
        NotificationCenter.default.addObserver(self, selector: #selector(toggleSideMenu), name: NSNotification.Name("toggleSideMenu"), object: nil)
        
        // This gets the response from the side menu close button
        NotificationCenter.default.addObserver(self, selector: #selector(closeSideMenu), name: NSNotification.Name("closeSideMenu"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(goToProfileVC), name: NSNotification.Name("goToProfileVC"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(signOutAndGoToLoginVC), name: NSNotification.Name("signOutAndGoToLoginVC"), object: nil)
        
        // This gets the response from the side menu when it is swiped
        NotificationCenter.default.addObserver(self, selector: #selector(closeSideMenu), name: NSNotification.Name("swipedLeftOnSideMenu"), object: nil)
                
        sideMenu.layer.zPosition = 100
        blackView.layer.zPosition = 99
        eventListView.layer.zPosition = 98
        blackView.isHidden = true
                
        let shadowPath = UIBezierPath(rect: sideMenu.bounds)
        sideMenu.layer.masksToBounds = false
        sideMenu.layer.shadowColor = UIColor.black.cgColor
        sideMenu.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        sideMenu.layer.shadowOpacity = 0
        sideMenu.layer.shadowPath = shadowPath.cgPath
        
        _fAuth = Auth.auth()
        _databaseRef = Database.database().reference().child(DatabaseStringReference.USERS_REF)
        print(_databaseRef!)
    }
    
    func closeMenu() {
        let width = 0 - UIConstants.SIDEBAR_WIDTH
        sideMenuConstraint.constant = CGFloat(width)
        eventListView.isUserInteractionEnabled = true
        blackView.isHidden = true
        sideMenu.layer.shadowOpacity = 0
    }
    
    @objc func toggleSideMenu() {
        sideMenuConstraint.constant = 0
        sideMenu.layer.shadowOpacity = 1.5
        eventListView.isUserInteractionEnabled = false
        blackView.isHidden = false
    }
    
    @objc func closeSideMenu() {
        closeMenu()
    }
    
    @objc func goToProfileVC(){
        closeMenu()
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let profileVC = storyBoard.instantiateViewController(withIdentifier: "profileVC") as! ProfileVC
        profileVC.userInfo = self.userInfo
        
        self.navigationController?.viewControllers.append(profileVC)
    }

    @objc func signOutAndGoToLoginVC() {
        Utilities.signOut(auth: Auth.auth())
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyBoard.instantiateViewController(withIdentifier: "loginVC") as! LoginVC
        self.navigationController?.viewControllers = [loginVC]
    }
}
