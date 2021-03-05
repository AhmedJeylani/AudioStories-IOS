//
//  RegisterVC+handlers.swift
//  AudioStories
//
//  Created by Ahmed Jeylani on 28/03/2020.
//  Copyright © 2020 Jeylani Technologies. All rights reserved.
//

import UIKit
import Firebase

extension RegisterVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // Below handles when an image is pressed
    @objc func handleSelectedProfileImage() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        createCameraAndGalleryAlert(picker: picker, sender: self)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        Utilities.createAlert(title: "Information", message: "You need to have a profile picture", sender: self)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
            profileImageView.contentMode = .scaleAspectFit
            profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func setImageViewSettings() {
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectedProfileImage)))
    }
    
    func createCameraAndGalleryAlert(picker: UIImagePickerController, sender: AnyObject) {
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
    
    func sendVerifcationEmail(user: User, email: String) {
        user.sendEmailVerification(completion: { (error) in
            
            if let emailVerificationError = error {
                Utilities.createAlert(title: "Error sending email verification", message: emailVerificationError.localizedDescription, sender: self)
            } else {
                let alert = UIAlertController(title: "Information",message: "Account created and Email Verification sent to " + email, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction) in
                    self.dismiss(animated: true) {
                        Utilities.signOut(auth: Auth.auth())
                        self.navigationController?.popViewController(animated: true)
                    }
                })
                
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    func isAllValid() -> Bool {
        if let emailText = emailTextField.text,
            let usernameText = usernameTextField.text,
            let passwordText = passwordTextField.text,
            let rePasswordText = rePasswordTextField.text {
            if emailText.isValid(validityType: .email)
                && usernameText.isValid(validityType: .username)
                && passwordText.isValid(validityType: .password)
                    && rePasswordText.matches(passwordText) {
                        return true
            }
        }
        return false
    }
    
    func checkValidity(textField: UITextField, errorLabel: UILabel, constraint: NSLayoutConstraint, validityType: String.ValidityType) {
        if let text = textField.text {
            if text.isValid(validityType: validityType) {
                constraint.constant = 15
                textField.setValid()
                errorLabel.isHidden = true
                return
            }
        }
        constraint.constant = 30
        textField.setInvalid()
        errorLabel.isHidden = false
        registerBtn.disable(title: nil)
    }
    
    func areAnyFieldsEmpty() -> Bool {
           if nameTextField.text!.isEmpty || usernameTextField.text!.isEmpty || emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty || rePasswordTextField.text!.isEmpty {
               return true
           } else {
               return false
           }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
