//
//  SingleFeedVC.swift
//  AudioStories
//
//  Created by Ahmed Jeylani on 03/07/2019.
//  Copyright © 2019 Jeylani Technologies. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

class SingleFeedVC: BaseVC, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var parentStoryProgressView: UIProgressView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var audioInfoLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var playParentStoryBtn: UIButton!
    @IBOutlet weak var chosenFeedImage: UIImageView!
    @IBOutlet weak var feedTableView: UITableView!
    @IBOutlet weak var addStoryBtn: UIButton!
    @IBOutlet weak var playAllBtn: UIButton!
    @IBOutlet weak var parentStoryView: UIView!
    @IBOutlet weak var emptyStateView: UIView!
    
    var _databaseRef:DatabaseReference?
    var _feedList = [Feed]()
    var _updater : CADisplayLink! = nil
    var _currentProgressView: UIProgressView! = nil
    var _audioPlayerList = [AVPlayer]();
    let _semaphore = DispatchSemaphore(value: 0)
    var _audioPlaying = false
    
    var chosenFeed:Feed = Feed()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        AudioPlayer.stop()
        
        setShadowOnView()
        feedTableView.separatorInset = UIEdgeInsets.zero
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()

        usernameLabel.text = chosenFeed.username
        audioInfoLabel.text = chosenFeed.info
        dateLabel.text = chosenFeed.date
        
        chosenFeedImage.loadImageUsingCache(feedId: chosenFeed.uniqueID!, uniqueId: chosenFeed.creatorID!, contentMode: .scaleAspectFit)
        _databaseRef = Database.database().reference()
        
        _audioPlayerList.append(downloadStrToAVPlayer(downloadStr: chosenFeed.audioRef)!)
        
        getListOfEvents()
        
        Utilities.showEmptyStateOrList(emptyStateView: emptyStateView, tableView: feedTableView, addStoryBtn: addStoryBtn, list: _feedList)
    }
    
    func getListOfEvents() {
        // This runs once and goes for all children under events!
        _databaseRef?.child(DatabaseStringReference.STORIES_REF).child(chosenFeed.uniqueID!).observe(.childAdded, with: { (dataSnapshot) in
            if let dictionary = dataSnapshot.value as? [String: AnyObject] {
                let singleFeed = Feed()
                singleFeed.setValuesForKeys(dictionary)
                
                self._feedList.append(singleFeed)
                self._audioPlayerList.append(self.downloadStrToAVPlayer(downloadStr: singleFeed.audioRef)!)
                
                self.feedTableView.isHidden = false

                // This will crash because of background thread, therefore run an async task
                DispatchQueue.main.async {
                    self.feedTableView.reloadData()
                }
                Utilities.showEmptyStateOrList(emptyStateView: self.emptyStateView, tableView: self.feedTableView, addStoryBtn: self.addStoryBtn, list: self._feedList)
            }
        })
    }
    
    func downloadStrToAVPlayer(downloadStr: String?) -> AVPlayer?{
        if let audioStringUrl = downloadStr, let audioUrl = URL(string: audioStringUrl) {
            return AVPlayer(url: audioUrl)
        } else {
            return nil
        }
    }
        
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Player ended")//TODO: Remove if not in use
    }
    
    func setShadowOnView() {
        parentStoryView.layer.shadowColor = UIColor.black.cgColor
        parentStoryView.layer.shadowOpacity = 0.5
        parentStoryView.layer.shadowOffset = CGSize(width: 0, height: 3)
        parentStoryView.layer.shadowRadius = 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return _feedList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! FeedTableViewCell
        let feed = _feedList[indexPath.row]
        
        Utilities.setPlaceholderImage(cell: cell)
        cell.profileImage.loadImageUsingCache(feedId: feed.uniqueID!, uniqueId: feed.creatorID!, contentMode: .redraw)
        
        cell.dateLabel.text = feed.date ?? "Date"
        cell.infoLabel.text = feed.info!
        cell.usernameLabel.text = feed.username!
        cell.singleFeed = feed
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @objc func trackAudio() {
        let currentTime = AudioPlayer.audioPlayer.currentTime()
        let currentSeconds =  CMTimeGetSeconds(currentTime)
        let fullDuration = AudioPlayer.audioPlayer.currentItem?.duration
        let fullDurationSeconds = CMTimeGetSeconds(fullDuration!)
        if currentSeconds == 0.0 {
            parentStoryProgressView.progress = 0.0
            return
        }
        
        //TODO: Display Timer?
        let currentPercentage = Float(currentSeconds / fullDurationSeconds)
        self.parentStoryProgressView.progress = currentPercentage
        
        if currentPercentage >= 1 {
            self.parentStoryProgressView.progress = 0.0
            self._updater.invalidate()
            AudioPlayer.stop()
        }
    }
    
    @IBAction func playAllBtnPressed(_ sender: Any) {
        if (!_audioPlaying) {
            self._audioPlaying = true
            playAllBtn.setTitle("Stop All", for: .normal)
            
            let dispatchQueue = DispatchQueue.global(qos: .background)
            dispatchQueue.async {
                for audio in self._audioPlayerList {
                    audio.isMuted = false
                    audio.volume = 1.0
                    audio.play()
                    
                    var currentTime = audio.currentTime()
                    var currentSeconds =  CMTimeGetSeconds(currentTime)
                    let fullDuration = audio.currentItem?.duration
                    let fullDurationSeconds = CMTimeGetSeconds(fullDuration!)
                    
                    while currentSeconds <= fullDurationSeconds && self._audioPlaying {
                        currentTime = audio.currentTime()
                        currentSeconds = CMTimeGetSeconds(currentTime)
                        self._semaphore.signal()
                    }
                    
                    if !self._audioPlaying {
                        self._semaphore.signal()
                    }
                    
                    audio.seek(to: CMTime.zero)
                    audio.pause()
                    self._semaphore.wait()
                }
                
                DispatchQueue.main.async {
                   self.playAllBtn.setTitle("Play All", for: .normal)
                }
                
                self._audioPlaying = false
            }
        } else {
            playAllBtn.setTitle("Play All", for: .normal)
            _audioPlaying = false
        }
    }
    
    @IBAction func playParentStoryBtnPressed(_ sender: Any) {
        if let audioStringUrl = chosenFeed.audioRef, let audioUrl = URL(string: audioStringUrl) {
            do {
                if AudioPlayer.isAudioPlaying() {
                    self.parentStoryProgressView.progress = 0.0
                    self._updater.invalidate()
                    AudioPlayer.stop()
                } else {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                    try AVAudioSession.sharedInstance().setActive(true)
                    self._updater = CADisplayLink(target: self, selector: #selector(trackAudio))
                    self._updater.preferredFramesPerSecond = 1
                    self._updater.add(to: .current, forMode: .common)
                    AudioPlayer.play(audioUrl: audioUrl, audioButton: playParentStoryBtn)
                    self.parentStoryProgressView.progress = 0.0
                }
            }
            catch {
                print("ERROR -- " + error.localizedDescription)//TODO: Add proper error handling
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        AudioPlayer.stop()
        _audioPlaying = false
        self.parentStoryProgressView.progress = 0.0
        if let updater = self._updater {
            updater.invalidate()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCreateAudioSegue" {
            if let createAudioController = segue.destination as? CreateAudioVC {
                createAudioController.chosenFeed = self.chosenFeed
                createAudioController.sentFromHomePage = false
            }
        }
    }
}
