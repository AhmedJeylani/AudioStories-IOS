//
//  CreateAudioVC+handlers.swift
//  AudioStories
//
//  Created by Ahmed Jeylani on 03/05/2020.
//  Copyright © 2020 Jeylani Technologies. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

extension CreateAudioVC : AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    func createTrackLayer() -> UIBezierPath {
        let center = timerLabel.center
        let trackLayer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: center, radius: 100, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)
        trackLayer.path = circularPath.cgPath
        if let color = UIColor(named: "trackLayerColor") {
            trackLayer.strokeColor = color.cgColor
        } else {
            trackLayer.strokeColor = UIColor.lightGray.cgColor
        }
        trackLayer.lineWidth = 10
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = CAShapeLayerLineCap.round
        timerView.layer.addSublayer(trackLayer)
        return circularPath
    }
    
    func createProgressTrack(circularPath: UIBezierPath) {
        //pi is half a circle
        _shapeLayer.path = circularPath.cgPath
        if let color = UIConstants.ENABLED_COLOR {
            _shapeLayer.strokeColor = color.cgColor
        } else {
            _shapeLayer.strokeColor = UIColor.red.cgColor
        }
        _shapeLayer.lineWidth = 10
        _shapeLayer.fillColor = UIColor.clear.cgColor
        _shapeLayer.lineCap = CAShapeLayerLineCap.round
        _shapeLayer.strokeEnd = 0
        timerView.layer.addSublayer(_shapeLayer)
    }
    
    func setupRecorder() -> Bool {
       let recordSettings = [AVFormatIDKey : Int(kAudioFormatMPEG4AAC),
           AVEncoderAudioQualityKey : AVAudioQuality.high.rawValue,
           AVNumberOfChannelsKey : 1,
           AVSampleRateKey : 12000 ] as [String : Any]

        do {
            try _recordingSession.setCategory(.playAndRecord, mode: .default)
            try _recordingSession.setActive(true)
            _audioRecorder = try AVAudioRecorder(url: getFileURL(), settings: recordSettings)
            _audioRecorder.delegate = self
            _audioRecorder.prepareToRecord()
            return true
        } catch {
            disableButtons()
            print("recording went wrong")//TODO: Display error for user?
            return false
        }
    }
    
    func getDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getFileURL() -> URL{
        _fileName = "audiostory_" + Utilities.getCurrentDateAndTimeFile() + ".aac"
        _filePath = getDirectory().appendingPathComponent(_fileName)
        return _filePath
    }
    
    func preparePlayer() {
        do {
            if _filePath != nil {
                try _recordingSession.overrideOutputAudioPort(.speaker)
                _audioPlayer = try AVAudioPlayer(contentsOf: _filePath, fileTypeHint: "aac")
                _audioPlayer.delegate = self
                _audioPlayer.volume = 1.0
                _audioPlayer.prepareToPlay()
            }
        } catch {
            print("play back went wrong")
        }
    }
    
    func sendStoryToDatabase(storyInfo:String) {
        var feedRef = Database.database().reference()

        if self.sentFromHomePage {
            feedRef = feedRef.child(DatabaseStringReference.FEED_REF)
        } else {
            feedRef = feedRef.child(DatabaseStringReference.STORIES_REF).child(self.chosenFeed.uniqueID!)
        }
        
        let audioStorageRef = Storage.storage().reference().child(DatabaseStringReference.AUDIO_STORY_STORAGE_REF)
        let metadata = StorageMetadata()
        metadata.contentType = ""
        let fullFileName = userInfo.uniqueID! + "-" + _fileName
        let audioLocationRef = audioStorageRef.child(fullFileName)
        audioLocationRef.putFile(from: _filePath as URL, metadata: .none) { (storageMetadata, error) in
            audioLocationRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    //Error occured
                    return
                }
                
                let audioPathURL = downloadURL.absoluteString
                let saveFeedRef = feedRef.childByAutoId()
                let feedKey = saveFeedRef.key

                let audioData = [DatabaseStringReference.UNIQUEID_KEY_NAME : feedKey!,
                                 DatabaseStringReference.DATE_KEY_NAME : Utilities.getCurrentDateAndTimeFeed(),
                                 DatabaseStringReference.USERNAME_KEY_NAME : self.userInfo.username!,
                                 DatabaseStringReference.INFO_KEY_NAME : storyInfo,
                                 DatabaseStringReference.AUDIOREF_KEY_NAME : audioPathURL,
                                 DatabaseStringReference.NO_LIKES_KEY_NAME : "0",
                                 DatabaseStringReference.NO_RECORDINGS_KEY_NAME : "0",
                                 DatabaseStringReference.CREATOR_ID_KEY_NAME : self.userInfo.uniqueID!,
                                 DatabaseStringReference.FILE_NAME_KEY_NAME : fullFileName] as [String : String]
                
                saveFeedRef.updateChildValues(audioData)
                
                if !self.sentFromHomePage {
                    let chosenFeedRef = Database.database().reference().child(DatabaseStringReference.FEED_REF)
                        .child(self.chosenFeed.uniqueID!)
                    let storiesNoRecRef = chosenFeedRef.child(DatabaseStringReference.NO_RECORDINGS_KEY_NAME)
                    storiesNoRecRef.observeSingleEvent(of: .value) { (snapshot) in
                        if let value = snapshot.value as? String {
                            let noRecordings = Int(value) ?? 0
                            let newRecordings = noRecordings + 1
                            chosenFeedRef.updateChildValues([DatabaseStringReference.NO_RECORDINGS_KEY_NAME: String(newRecordings)])
                        }
                    }
                }
            }
        }
    }
    
    func disableButtons() {
        playStopBtn.disable(title: nil)
        doneBtn.disable(title: nil)
        
    }
    
    func enableButtons() {
        playStopBtn.enable(title: nil)
        doneBtn.enable(title: nil)
    }
    
    func startAnimation() {
        timerLabel.text = "00"
        disableButtons()
        // What this is going to animate
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.toValue = 1
        basicAnimation.duration = 25
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = true
        
        _timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerHandler), userInfo: .none, repeats: true)
        _shapeLayer.add(basicAnimation, forKey: "yourSoBasic")
    }
    
    func stopAnimationAndRecording() {
        _shapeLayer.removeAllAnimations()
        // timerLabel.text = "00"
        _timer.invalidate()
        if _audioPlayer != nil {
            _audioRecorder.stop()
        }
        _audioRecorder = nil
        _counter = 0
        enableButtons()
    }
    
    @objc func longPressedRecord(press: UILongPressGestureRecognizer) {
        if press.state == .began {
            if (_audioRecorder == nil) {
                if !setupRecorder() {
                    press.state = .cancelled
                    _audioRecorder = nil
                    _filePath = nil
                    _fileName = nil
                    disableButtons()
                    Utilities.createAlert(title: "Error attempting to record", message: "This is could be due to your micrphone being unavailable. If the problem persists, contact support", sender: self)
                    return
                }
                
                _audioRecorder.record()
                startAnimation()
                print("Recording")
            }
            else {
                disableButtons()
                print("Can't Record")
            }
        } else if press.state == .ended {
            if _audioRecorder != nil {
                stopAnimationAndRecording()
                print("Stop Recording")
            }
        }
    }
    
    @objc func timerHandler() {
        _counter += 1
        if _counter < 10 {
            timerLabel.text = "0" + String(_counter)
        } else {
            timerLabel.text = String(_counter)
        }
        
        if _counter == 21 {
            stopAnimationAndRecording()
        }
    }
}
