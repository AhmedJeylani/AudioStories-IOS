//
//  SideMenuVC.swift
//  AudioStories
//
//  Created by Ahmed Jeylani on 03/07/2019.
//  Copyright © 2019 Jeylani Technologies. All rights reserved.
//

import UIKit
import Firebase

class SideMenuVC: BaseVC, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var menuTableView: UITableView!
    
    var _menuItems = [MenuItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fAuth = Auth.auth()
        if let user = fAuth.currentUser {
            profileImageView.loadImageUsingCache(feedId: nil, uniqueId: userInfo.uniqueID!, contentMode: .scaleAspectFit)
            usernameLabel.text = userInfo.username
            emailLabel.text = user.email
        }
        loadMenuItems()
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipedLeftOnView))
        swipeGesture.direction = .left
        self.view.addGestureRecognizer(swipeGesture)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func loadMenuItems() {
        _menuItems.append(MenuItem(menuImageName: "person_icon", menuLabel: "Profile"))
        _menuItems.append(MenuItem(menuImageName: "signout_icon", menuLabel: "Sign Out"))
        self.menuTableView.reloadData()
    }
    
    @objc func swipedLeftOnView() {
        NotificationCenter.default.post(name: NSNotification.Name("swipedLeftOnSideMenu"), object: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return _menuItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! MenuTableViewCell
        let item = _menuItems[indexPath.row]
        
        cell.itemLabel.text = item.menuLabel
        cell.itemImage.image = UIImage(named: item.menuImageName!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menuItem = _menuItems[indexPath.row]
        
        switch menuItem.menuLabel {
        case "Sign Out":
            NotificationCenter.default.post(name: NSNotification.Name("signOutAndGoToLoginVC"), object: nil)
            break;
            
        case "Profile":
            NotificationCenter.default.post(name: NSNotification.Name("goToProfileVC"), object: nil)
            break;
            
        default:
            break;
        }
    }
    
    @IBAction func closeSideMenuBtnTapped(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name("closeSideMenu"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let user = Cache.GetUserInfo()!
        if user.imageRef != userInfo.imageRef! {
            userInfo = user
            profileImageView.loadImageUsingCache(feedId: nil, uniqueId: userInfo.uniqueID!, contentMode: .scaleAspectFit)
        }
    }
}
