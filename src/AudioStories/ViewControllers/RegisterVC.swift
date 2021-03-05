//
//  RegisterVC.swift
//  AudioStories
//
//  Created by Ahmed Jeylani on 28/03/2020.
//  Copyright © 2020 Jeylani Technologies. All rights reserved.
//

import UIKit
import Firebase

class RegisterVC: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var rePasswordTextField: UITextField!
    @IBOutlet weak var registerBtn: CustomDefaultUIButton!
    @IBOutlet weak var usernameErrorLabel: UILabel!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var rePasswordErrorLabel: UILabel!
    @IBOutlet weak var usernameConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailConstraint: NSLayoutConstraint!
    @IBOutlet weak var passwordConstraint: NSLayoutConstraint!
    
    var _userRef:DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _userRef = Database.database().reference().child(DatabaseStringReference.USERS_REF)
        profileImageView.image = UIImage(named: "camera_large")
        setImageViewSettings()
        usernameErrorLabel.isHidden = true
        usernameConstraint.constant = 15
        emailErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true
        rePasswordErrorLabel.isHidden = true
        registerBtn.disable(title: nil)
    }
    
    func registerUserWithProfileImage(user: User, email: String, password: String) {
        let storageRef = Storage.storage().reference().child(DatabaseStringReference.PROFILE_IMAGES_STORAGE_REF)        
        
        if let uploadImageData = self.profileImageView.image!.jpegData(compressionQuality: 0.8) {
            // This controls the type of data!
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            let fileName = user.uid + DatabaseStringReference.PROFILE_IMAGE_NAME
            let storageFileRef = storageRef.child(fileName)
            storageFileRef.putData(uploadImageData, metadata: metadata) { (metadata, error) in
                guard metadata != nil else {
                    // Uh-oh, an error occurred!
                    Utilities.createAlert(title: "Error Uploading Image", message: error?.localizedDescription ?? "There was an error uploading image", sender: self)
                    return
                }
                
                storageFileRef.downloadURL { (url, error) in
                    guard let downloadUrl = url else {
                        Utilities.createAlert(title: "Error Uploading Image", message: error?.localizedDescription ?? "There was an error uploading image", sender: self)
                        return
                    }
                    
                    self.addUserInfoToDatabase(user: user, email: email, downloadUrl: downloadUrl.absoluteString)
                }
            }
        }
    }
    
    func startRegistrationProcess(withImage: Bool) {
        let email = emailTextField.text
        let password = passwordTextField.text
        
        Auth.auth().signInAnonymously { (authResult, error) in
            guard let user = authResult?.user else {
                Utilities.createAlert(title: "Error", message: "There was an error registering your account", sender: self)
                print(error?.localizedDescription ?? "unknown error when creating anonymous user")
                return
            }
            
            let isAnonymous = user.isAnonymous
            
            if isAnonymous {
                self._userRef.observeSingleEvent(of: .value) { (dataSnapshot) in
                    var usernameChecked = false
                    for child in dataSnapshot.children.allObjects as! [DataSnapshot] {
                        let userInfo = BaseUser()
                        if let dictionary = child.value as? [String: AnyObject] {
                            userInfo.setValuesForKeys(dictionary)

                            if userInfo.username?.lowercased() == self.usernameTextField.text!.lowercased(){
                                Utilities.createAlert(title: "Error", message: "Username already exists, please choose another.", sender: self)
                                Auth.auth().currentUser?.delete(completion: .none)
                                Utilities.signOut(auth: Auth.auth())
                                return
                            } else {
                                usernameChecked = true
                            }
                        } else {
                            Utilities.createAlert(title: "Error", message: "Error getting data from the database", sender: self) // Check this error handling
                            Auth.auth().currentUser?.delete(completion: .none)
                            Utilities.signOut(auth: Auth.auth())
                            usernameChecked = false
                            return
                        }
                    }
                    if usernameChecked {
                        self.registerBtn.disable(title: "REGISTERING...")
                        // This deletes Anonymous User
                        Auth.auth().currentUser?.delete(completion: .none)
                        Utilities.signOut(auth: Auth.auth())
                        Auth.auth().createUser(withEmail: email!, password: password!) { (authResult, error) in
                            guard let user = authResult?.user, error == nil else {
                                Utilities.createAlert(title: "Error Creating your Account", message:  error?.localizedDescription ?? "Unknown error", sender: self)
                                self.registerBtn.enable(title: "REGISTER")
                                return
                            }
                            
                            if withImage {
                                self.registerUserWithProfileImage(user: user, email: email!, password: password!)
                            } else {
                                self.addUserInfoToDatabase(user: user, email: email!, downloadUrl: nil)
                            }
                        }
                    }
                }
                
            }
        }
    }
    
    func addUserInfoToDatabase(user: User, email: String, downloadUrl: String?) {
        let uniqueId = user.uid
        let uniqueIdRef = self._userRef.child(user.uid)
        let name = self.nameTextField.text!
        let username = self.usernameTextField.text!
        let userType = "standard"
        let bio = ""
        
        uniqueIdRef.setValue([
            DatabaseStringReference.IMAGE_REF_KEY_NAME: downloadUrl ?? "",
            DatabaseStringReference.USERNAME_KEY_NAME: username,
            DatabaseStringReference.UNIQUEID_KEY_NAME: uniqueId,
            DatabaseStringReference.NAME_KEY_NAME: name,
            DatabaseStringReference.USER_TYPE_KEY_NAME: userType,
            DatabaseStringReference.BIO_KEY_NAME: bio
        ])
        
        self.sendVerifcationEmail(user: user, email: email)
    }
    
    @IBAction func usernameTextFieldChanged(_ sender: Any) {
        checkValidity(textField: usernameTextField, errorLabel: usernameErrorLabel, constraint: usernameConstraint, validityType: .username)
        if isAllValid() {
            registerBtn.enable(title: nil)
        }
    }
    
    @IBAction func emailTextFieldChanged(_ sender: Any) {
        checkValidity(textField: emailTextField, errorLabel: emailErrorLabel, constraint: emailConstraint, validityType: .email)
        if isAllValid() {
            registerBtn.enable(title: nil)
        }
    }
    @IBAction func passwordTextFieldChanged(_ sender: Any) {
        checkValidity(textField: passwordTextField, errorLabel: passwordErrorLabel, constraint: passwordConstraint, validityType: .password)
        if isAllValid() {
            registerBtn.enable(title: nil)
        }
    }
    @IBAction func rePasswordTextFieldChanged(_ sender: Any) {
        if let pass = passwordTextField.text, let rePass = rePasswordTextField.text {
            if rePass.matches(pass) {
                rePasswordTextField.setValid()
                rePasswordErrorLabel.isHidden = true
                if isAllValid() {
                    registerBtn.enable(title: nil)
                }
                return
            }
        }
        rePasswordTextField.setInvalid()
        rePasswordErrorLabel.isHidden = false
        registerBtn.disable(title: nil)
    }
    
    @IBAction func registerBtnPressed(_ sender: Any) {
        if areAnyFieldsEmpty() {
            Utilities.createAlert(title: "Error", message: "Fill in all Fields", sender: self)
        } else if profileImageView.image == nil || profileImageView.image == UIImage(named: "camera_large") {
            let alert = UIAlertController(title: "Warning", message: "Are you sure you will like to continue without uploading a profile image.", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default) { (_) in
                self.startRegistrationProcess(withImage: false)
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(yesAction)
            self.present(alert, animated: true, completion: nil)
            
        } else {
            startRegistrationProcess(withImage: true)
        }
    }
}
