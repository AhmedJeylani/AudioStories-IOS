//
//  CreateAudioVC.swift
//  AudioStories
//
//  Created by Ahmed Jeylani on 19/07/2019.
//  Copyright © 2019 Jeylani Technologies. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

class CreateAudioVC: BaseVC {

    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var playStopBtn: UIButton!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    
    var _recordingSession:AVAudioSession!
    var _audioRecorder:AVAudioRecorder!
    var _audioPlayer:AVAudioPlayer!
    var _fileName:String!
    var _filePath:URL!
    var _counter = 0;
    var _timer = Timer()
    let _shapeLayer = CAShapeLayer()
    let _playImage = UIImage(named: "play_icon")
    let _stopImage = UIImage(named: "stop_icon")
    var _audioPlaying:Bool = false
    
    var sentFromHomePage:Bool = true
    var chosenFeed:Feed = Feed()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //create my Track Layer
        let circularPath = createTrackLayer()
        createProgressTrack(circularPath: circularPath);
        
        _recordingSession = AVAudioSession.sharedInstance()
        AVAudioSession.sharedInstance().requestRecordPermission { (hasPermission) in
            if hasPermission {
                //TODO: log they have permissions?
            }
        }
        
        let longPressGestureRecog = UILongPressGestureRecognizer(target: self, action: #selector(longPressedRecord(press:)))
        recordBtn.addGestureRecognizer(longPressGestureRecog)
        disableButtons()
    }
    
    @IBAction func playAudioBtnPressed(_ sender: Any) {
        if _audioPlaying {
            if _audioPlayer != nil {
                _audioPlayer.stop()
                playStopBtn.setImage(_playImage, for: .normal)
                _audioPlaying = false
                print("playing")
            }
        } else {
            preparePlayer()
            if(_audioPlayer != nil) {
                _audioPlayer.play()
                playStopBtn.setImage(_stopImage, for: .normal)
                _audioPlaying = true
                print("stopped")//Proper Logging? internal loggin?
            }
        }
    }
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        if _fileName == nil || _filePath == nil {
            Utilities.createAlert(title: "Error", message: "Please record a story", sender: self)
            return
        }
        
        if self.sentFromHomePage {
            let alert = UIAlertController(title: "Information", message: "Information about your story", preferredStyle: .alert)
            
            alert.addTextField { (textField) in }
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
                
                if textField!.text!.isEmpty {
                    self.dismiss(animated: true) {
                        Utilities.createAlert(title: "Error", message: "your story needs to have a description", sender: self)
                    }
                    return
                } else {
                    self.sendStoryToDatabase(storyInfo: textField!.text!)
                    self.navigationController?.popViewController(animated: true)
                    self.dismiss(animated: true, completion: nil)//TODO: possible remove if not needed?
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak alert] (_) in
                self.dismiss(animated: true, completion: nil)//TODO: possible remove if not needed?
            }))
            
            self.present(alert, animated: true, completion: nil)
        } else {
            self.sendStoryToDatabase(storyInfo: "")
            self.navigationController?.popViewController(animated: true)
        }
    }
}
