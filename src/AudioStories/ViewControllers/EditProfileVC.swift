//
//  EditProfileVC.swift
//  AudioStories
//
//  Created by Ahmed Jeylani on 02/05/2020.
//  Copyright © 2020 Jeylani Technologies. All rights reserved.
//

import UIKit
import Firebase

class EditProfileVC: BaseVC {

    @IBOutlet weak var saveBtn: CustomDefaultUIButton!
    @IBOutlet weak var sendResetPasswordBtn: CustomDefaultUIButton!
    @IBOutlet weak var profileImageView: CustomDefaultUIImageView!
    @IBOutlet weak var sendResetPassConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImageViewSettings()
        profileImageView.loadImageUsingCache(feedId: nil, uniqueId: userInfo.uniqueID!, contentMode: .scaleAspectFit)
        saveBtn.isHidden = true
        sendResetPassConstraint.constant = 40
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        let databaseRef:DatabaseReference = Database.database().reference()
        let userRef = databaseRef.child(DatabaseStringReference.USERS_REF)
        let storageRef = Storage.storage().reference().child(DatabaseStringReference.PROFILE_IMAGES_STORAGE_REF)
        let uniqueIdRef = userRef.child(userInfo.uniqueID!)
        saveBtn.disable(title: "UPDATING...")
        if let uploadImageData = self.profileImageView.image!.jpegData(compressionQuality: 0.8) {
            
            // This controls the type of data!
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            let fileName = userInfo.uniqueID! + DatabaseStringReference.PROFILE_IMAGE_NAME
            let storageFileRef = storageRef.child(fileName)
            storageFileRef.putData(uploadImageData, metadata: metadata) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    Utilities.createAlert(title: "Error Uploading Image", message: error?.localizedDescription ?? "There was an error uploading image", sender: self)
                    self.saveBtn.enable(title: "UPDATE PROFILE IMAGE")
                    return
                }
               
                storageFileRef.downloadURL { (url, error) in
                    guard let downloadUrl = url else {
                       //Error occured
                        self.saveBtn.enable(title: "UPDATE PROFILE IMAGE")
                        return
                    }
                    uniqueIdRef.updateChildValues([
                       DatabaseStringReference.IMAGE_REF_KEY_NAME: downloadUrl.absoluteString,
                       DatabaseStringReference.FILE_NAME_KEY_NAME: fileName
                    ])
                    self.userInfo.imageRef = downloadUrl.absoluteString
                    Cache.SetUserInfo(userInfo: self.userInfo)
                    Cache.imageCache.removeAllObjects()
                    self.saveBtn.enable(title: "UPDATE PROFILE IMAGE")
                    self.saveBtn.isHidden = true
                    self.sendResetPassConstraint.constant = 40
                    
                    DispatchQueue.main.async {
                        self.profileImageView.downloadAndCacheImage(feedId: nil, uniqueId: self.userInfo.uniqueID!, contentMode: .scaleAspectFit)
                    }
                }
            }
        }
    }
    
    @IBAction func sendResetPasswordBtnPressed(_ sender: Any) {
        if let currentUser = Auth.auth().currentUser {
            if let emailAddress = currentUser.email {
                Auth.auth().sendPasswordReset(withEmail: emailAddress) { (errorResponse) in
                    if let error = errorResponse {
                        ErrorAlert.noUserAvailable(error: error, displayMessage: "", sender: self)
                        return
                    }
                    //TODO: make the following in a method
                    let alert = UIAlertController(title: "Info",message: "Password reset email has been sent, please check your junk mail if you cannot find it. The app will sign you out. Please reset your password before you sign in.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default) { (_) in
                        Utilities.signOut(auth: Auth.auth())
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let loginVC = storyBoard.instantiateViewController(withIdentifier: "loginVC") as! LoginVC
                        self.navigationController?.viewControllers = [loginVC]
                    }
                    
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
}
