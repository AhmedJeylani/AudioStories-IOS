//
//  EditProfileVC+handlers.swift
//  AudioStories
//
//  Created by Ahmed Jeylani on 02/05/2020.
//  Copyright © 2020 Jeylani Technologies. All rights reserved.
//

import UIKit

extension EditProfileVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // Below handles when an image is pressed
    @objc func handleSelectedProfileImage() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        createCameraAndGalleryAlert(picker: picker, sender: self)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
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
            saveBtn.isHidden = false
            sendResetPassConstraint.constant = 140
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
}
// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
