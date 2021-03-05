//
//  DatabaseStringReference.swift
//  AudioStories
//
//  Created by Ahmed Jeylani on 03/07/2019.
//  Copyright © 2019 Jeylani Technologies. All rights reserved.
//

import UIKit

class DatabaseStringReference {
    // Firebase Storage References
    static let PROFILE_IMAGES_STORAGE_REF = "Profile Images"
    static let AUDIO_STORY_STORAGE_REF = "Audio Stories"
    
    //Firebase Database References
    static let USERS_REF = "Users"
    static let FEED_REF = "Feed"
    static let STORIES_REF = "Stories"
    static let USERS_LIKED_MESSAGES_REF = "Users Liked Stories"
    
    //Shared Key Names
    static let UNIQUEID_KEY_NAME = "uniqueID"
    static let IMAGE_REF_KEY_NAME = "imageRef"
    static let DATE_KEY_NAME = "date"
    static let USERNAME_KEY_NAME = "username"
    static let NAME_KEY_NAME = "name"
    static let FILE_NAME_KEY_NAME = "fileName"
    
    //Standard User Key Name
    static let BIO_KEY_NAME = "bio"
    static let USER_TYPE_KEY_NAME = "userType"
    
    //Feed Key Name
    static let INFO_KEY_NAME = "info"
    static let AUDIOREF_KEY_NAME = "audioRef"
    static let NO_RECORDINGS_KEY_NAME = "noRecordings"
    static let NO_LIKES_KEY_NAME = "noLikes"
    static let CREATOR_ID_KEY_NAME = "creatorID"
    
    //Profile Image Name Constant
    static let PROFILE_IMAGE_NAME = "-profile_image.jpg"
}
