//
//  SCMethods.swift
//  AudioStories
//
//  Created by Ahmed Jeylani on 03/07/2019.
//  Copyright © 2019 Jeylani Technologies. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class Utilities {
    static func createAlert(title: String, message: String, sender: AnyObject) {
        let alert = UIAlertController(title: title,message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(okAction)
        sender.present(alert, animated: true, completion: nil)
    }
    
    static func signOut(auth: Auth) {
        do {
            try auth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)//TODO: Proper error handling
        }
    }
    
    static func createCameraAndGalleryAlert(picker: UIImagePickerController, sender: AnyObject) {
        let photoSourceActionSheet = UIAlertController(title: "Photo Source", message: "Choose where to get your image from", preferredStyle: .actionSheet)
        
        photoSourceActionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            picker.sourceType = .camera
            sender.present(picker,animated: true, completion: nil)
        }))
        
        photoSourceActionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction) in
            picker.sourceType = .photoLibrary
            sender.present(picker,animated: true, completion: nil)
        }))
        
        photoSourceActionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        sender.present(photoSourceActionSheet, animated: true, completion: nil)
    }
    
    static func convertToUrlSetImage(imageUrlString: String?, imageView: UIImageView, contentMode: UIView.ContentMode) {
        if let urlString = imageUrlString {
            if !urlString.isEmpty {
                let url = URL(string: urlString)
                imageView.kf.setImage(with: url)
                imageView.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: nil) { (image, error, cacheType, url) in
                    imageView.contentMode = contentMode
                    imageView.layer.borderWidth = 0
                }
                imageView.contentMode = contentMode
            }
        }
        if imageView.image == UIImage(named: "person_icon") {
            imageView.contentMode = .center
            imageView.layer.borderWidth = 3
        }
    }

    // Fixes duplicated image and wrong content mode
    static func setPlaceholderImage(cell: FeedTableViewCell) {
        cell.profileImage.image = UIImage(named: "person_icon")! // Fixes
        cell.profileImage.contentMode = .scaleAspectFit // Fixes duplicated image and wrong content mode
    }
    
    static func getCurrentDateAndTimeFile() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MM_dd_yy-HHmmss"
        
        return dateFormatter.string(from: date)
    }
    
    static func getCurrentDateAndTimeFeed() -> String {
                
        let date = Date()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MM/dd/yy"
        
        return dateFormatter.string(from: date)
    }

    static func showEmptyStateOrList(emptyStateView: UIView, tableView: UITableView, addStoryBtn: UIButton, list: [Feed]) {
        if list.isEmpty {
            emptyStateView.isHidden = false
            tableView.isHidden = true
            addStoryBtn.isHidden = true
        } else {
            emptyStateView.isHidden = true
            tableView.isHidden = false
            addStoryBtn.isHidden = false
        }
    }
    
    static func setNavigationBar(sender: AnyObject) {
        sender.navigationController?.navigationItem.backBarButtonItem?.isEnabled = false
        sender.navigationController?.navigationBar.isHidden = false
        sender.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        sender.navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        sender.navigationController?.navigationBar.barTintColor = UIColor(named: "primaryTitleBarColor")
        sender.navigationController?.navigationBar.isTranslucent = false
        sender.navigationController?.navigationBar.tintColor = .white
    }
    
    static func getUserDetails(user: User) -> ContainerVC? {
        var containerVC: ContainerVC?
        let databaseRef = Database.database().reference().child(DatabaseStringReference.USERS_REF)
        databaseRef.child(user.uid).observeSingleEvent(of: .value) { (dataSnapshot) in
            // This gets the data from firebase and stores the values as an object by initialising it in the
            let userInfo = BaseUser()
            if let dictionary = dataSnapshot.value as? [String: AnyObject] {
                userInfo.setValuesForKeys(dictionary)
            }
            
            Cache.SetUserInfo(userInfo: userInfo)

            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            containerVC = storyBoard.instantiateViewController(withIdentifier: "containerVC") as? ContainerVC
        }
        return containerVC
    }
}

//TODO: move to an extension class?
extension String {
    
    func stringByAppendingPathComponent(path: String) -> String {
        let nsSt = self as NSString
        return nsSt.appendingPathComponent(path)
    }
}
