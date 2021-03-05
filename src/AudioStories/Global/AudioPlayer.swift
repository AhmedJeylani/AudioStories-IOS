//
//  AudioPlayer.swift
//  AudioStories
//
//  Created by Ahmed Jeylani on 15/03/2020.
//  Copyright © 2020 Jeylani Technologies. All rights reserved.
//

import UIKit
import AVFoundation

class AudioPlayer {
    
    public static var audioPlayer:AVPlayer!
    private static let _playImage = UIImage(named: "play_icon")
    private static let _stopImage = UIImage(named: "stop_icon")
    private static var _storeButton:UIButton!
    
    static func play (audioUrl:URL, audioButton:UIButton?) {
        if audioPlayer == nil {
            audioPlayer = AVPlayer(url: audioUrl)
            audioPlayer.isMuted = false
            audioPlayer.volume = 1.0
            audioPlayer.play()
            
            if let button = audioButton {
                button.setImage(_stopImage, for: .normal)
                _storeButton = button
            }
        } else {
            print("already Playing")
        }
    }
    
    static func stop() {
        if audioPlayer != nil {
            self.audioPlayer.pause()
            self.audioPlayer = nil
            _storeButton.setImage(_playImage, for: .normal)
        }
    }
    
    static func isAudioPlaying() -> Bool {
        if audioPlayer != nil {
            return true
        } else {
            return false
        }
    }
}
