//
//  UIImageViewExtension.swift
//  AudioStories
//
//  Created by Ahmed Jeylani on 04/05/2020.
//  Copyright © 2020 Jeylani Technologies. All rights reserved.
//

import UIKit
import Firebase

extension UIImageView {
        
    public func downloadAndCacheImage(feedId: String?, uniqueId: String, contentMode: ContentMode) {

        let storageRef = Storage.storage().reference().child(DatabaseStringReference.PROFILE_IMAGES_STORAGE_REF).child(uniqueId + DatabaseStringReference.PROFILE_IMAGE_NAME)
        
        storageRef.downloadURL { (responseUrl, error) in
            if let error = error {
                print("Error getting download URL" + error.localizedDescription)
                self.contentMode = .center
            } else {
                if let url = responseUrl {
                    self.kf.setImage(with: url)
                    self.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: nil) { (image, error, cacheType, url) in
                        self.contentMode = contentMode
                        self.layer.borderWidth = 0
                        if let id = feedId {
                            Cache.imageCache.setObject(image!, forKey: id as NSString)
                        } else {
                            Cache.imageCache.setObject(image!, forKey: uniqueId as NSString)
                        }
                    }
                    self.contentMode = contentMode
                    if self.image == UIImage(named: "person_icon") {
                        self.contentMode = .center
                        self.layer.borderWidth = 3
                        self.layer.borderColor = UIColor(named: "borderColor")?.cgColor
                    }
                }
            }
        }
    }
    
    public func loadImageUsingCache(feedId: String?, uniqueId: String, contentMode: ContentMode) {        
        if let id = feedId {
            if let image = Cache.imageCache.object(forKey: id as NSString) {
                self.contentMode = contentMode
                self.layer.borderWidth = 0
                self.layer.borderColor = UIColor(named: "borderColor")?.cgColor
                self.image = image
            } else {
                downloadAndCacheImage(feedId: feedId, uniqueId: uniqueId, contentMode: contentMode)
            }
        } else {
            if let image = Cache.imageCache.object(forKey: uniqueId as NSString) {
                self.contentMode = contentMode
                self.layer.borderWidth = 0
                self.image = image
            } else {
                downloadAndCacheImage(feedId: feedId, uniqueId: uniqueId, contentMode: contentMode)
            }
        }
    }
}
