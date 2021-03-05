//
//  FeedTableViewCell.swift
//  AudioStories
//
//  Created by Ahmed Jeylani on 03/07/2019.
//  Copyright © 2019 Jeylani Technologies. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

class FeedTableViewCell: UITableViewCell, AVAudioPlayerDelegate {
    
    @IBOutlet weak var profileImage: CustomBorderUIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var audioProgressBar: UIProgressView!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var noRecordingLabel: UILabel!
    
    var singleFeed:Feed!
    var _updater : CADisplayLink! = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //SCMethods.setButtonRound(button: playBtn)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
        
    @IBAction func pressPlay(_ sender: Any) {
        if let audioStringUrl = singleFeed.audioRef, let audioUrl = URL(string: audioStringUrl) {
            do {
                if AudioPlayer.isAudioPlaying() && self._updater != nil {
                    self.audioProgressBar.progress = 0.0
                    self._updater.invalidate()
                    AudioPlayer.stop()
                    print("stop playing")
                } else if AudioPlayer.isAudioPlaying() {
                    print("already playing another audio")
                } else {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                    try AVAudioSession.sharedInstance().setActive(true)
                    self._updater = CADisplayLink(target: self, selector: #selector(trackAudio))
                    self._updater.preferredFramesPerSecond = 1
                    self._updater.add(to: .current, forMode: .common)
                    AudioPlayer.play(audioUrl: audioUrl, audioButton: playBtn)
                    print("Audio playing")
                    self.audioProgressBar.progress = 0.0
                }
            }
            catch {
                print("ERROR -- " + error.localizedDescription)//TODO: Display Error for user!
            }
        }
    }
    
    @objc func trackAudio() {
        if !AudioPlayer.isAudioPlaying() {
            self.audioProgressBar.progress = 0.0
            self._updater.invalidate()
            return
        }
        
        let currentTime = AudioPlayer.audioPlayer.currentTime()
        let currentSeconds =  CMTimeGetSeconds(currentTime)
        let fullDuration = AudioPlayer.audioPlayer.currentItem?.duration
        let fullDurationSeconds = CMTimeGetSeconds(fullDuration!)
        
        if(currentSeconds == 0.0) {
            self.audioProgressBar.progress = 0.0
            return
        }
        //Todo: Timer to show progress?
        let currentPercentage = Float(currentSeconds / fullDurationSeconds)
        print(currentPercentage)
        self.audioProgressBar.progress = currentPercentage
        
        if currentPercentage >= 1 {
            self.audioProgressBar.progress = 0.0
            self._updater.invalidate()
            AudioPlayer.stop()
        }
    }
}
