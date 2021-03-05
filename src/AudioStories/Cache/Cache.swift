//
//  Cache.swift
//  AudioStories
//
//  Created by Ahmed Jeylani on 03/05/2020.
//  Copyright © 2020 Jeylani Technologies. All rights reserved.
//

import Foundation
import UIKit

class Cache {
    static let cache = NSCache<NSString, NSDictionary>()
    static let imageCache = NSCache<NSString, UIImage>()
    private static let USER_INFO_KEY: String = "userInfo"
    
    
    static func SetUserInfo(userInfo: BaseUser) {
        let dictionary = [
            DatabaseStringReference.IMAGE_REF_KEY_NAME: userInfo.imageRef!,
            DatabaseStringReference.USERNAME_KEY_NAME: userInfo.username!,
            DatabaseStringReference.UNIQUEID_KEY_NAME: userInfo.uniqueID!,
            DatabaseStringReference.NAME_KEY_NAME: userInfo.name!,
            DatabaseStringReference.USER_TYPE_KEY_NAME: userInfo.userType!,
            DatabaseStringReference.BIO_KEY_NAME: userInfo.bio!
        ] as NSDictionary
        cache.setObject(dictionary, forKey: USER_INFO_KEY as NSString)
    }
    
    static func GetUserInfo() -> BaseUser?{
        if let nsDictionary = cache.object(forKey: USER_INFO_KEY as NSString) {
            let userInfo = BaseUser()
            var dictionary = [String: Any]()
            for (key, value) in nsDictionary {
                dictionary[key as! String] = value
            }
            userInfo.setValuesForKeys(dictionary)
            return userInfo
        }
        return nil
    }
}
