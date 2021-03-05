//
//  HomeVC.swift
//  AudioStories
//
//  Created by Ahmed Jeylani on 03/07/2019.
//  Copyright © 2019 Jeylani Technologies. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import AVFoundation

class HomeVC: BaseVC, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var feedTableView: UITableView!
    @IBOutlet weak var emptyStateView: UIView!
    
    var _databaseRef:DatabaseReference!
    var _feedList = [Feed]()
    var _chosenFeed:Feed = Feed()
    let _cellId = "cellId"
    var _chosenIndex = 0
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        feedTableView.delegate = self;
        feedTableView.dataSource = self;
        feedTableView.separatorInset = UIEdgeInsets.zero
        
        _databaseRef = Database.database().reference()
        
        listOfFeedEvents()
        
        Utilities.showEmptyStateOrList(emptyStateView: emptyStateView, tableView: feedTableView, addStoryBtn: addBtn, list: _feedList)
    }
    
    func listOfFeedEvents() {
        let feedRef = _databaseRef.child(DatabaseStringReference.FEED_REF)
        
        // This runs once and goes for all children under events!
        feedRef.observe(.childAdded, with: { (dataSnapshot) in
            if let dictionary = dataSnapshot.value as? [String: AnyObject] {
                let singleFeed = Feed()
                singleFeed.setValuesForKeys(dictionary)
                
                self._feedList.insert(singleFeed, at: 0)
                
                // This will crash because of background thread, therefore run an async task
                DispatchQueue.main.async {
                    self.feedTableView.reloadData()
                }
                Utilities.showEmptyStateOrList(emptyStateView: self.emptyStateView, tableView: self.feedTableView, addStoryBtn: self.addBtn, list: self._feedList)
            }
        })
        
        feedRef.observe(.childChanged, with: { (dataSnapshot) in
            if let dictionary = dataSnapshot.value as? [String: AnyObject] {
                let singleFeed = Feed()
                singleFeed.setValuesForKeys(dictionary)

                let feedIndex = self._feedList.firstIndex(where: {$0.uniqueID == singleFeed.uniqueID})
                
                if let index = feedIndex {
                    self._feedList[index].noRecordings = singleFeed.noRecordings
                }
                
                // This will crash because of background thread, therefore run an async task
                DispatchQueue.main.async {
                    self.feedTableView.reloadData()
                }
            }
        })
        
        feedRef.observe(.childRemoved) { (dataSnapshot) in
            if let dictionary = dataSnapshot.value as? [String: AnyObject] {
                let singleFeed = Feed()
                singleFeed.setValuesForKeys(dictionary)
                
                self._feedList = self._feedList.filter(){ $0.uniqueID != singleFeed.uniqueID}
                
                // This will crash because of background thread, therefore run an async task
                DispatchQueue.main.async {
                    self.feedTableView.reloadData()
                }
                Utilities.showEmptyStateOrList(emptyStateView: self.emptyStateView, tableView: self.feedTableView, addStoryBtn: self.addBtn, list: self._feedList)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return _feedList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! FeedTableViewCell
        let feed = _feedList[indexPath.row]
        
        Utilities.setPlaceholderImage(cell: cell)
        cell.profileImage.loadImageUsingCache(feedId: feed.uniqueID!, uniqueId: feed.creatorID!, contentMode: .scaleAspectFit)
        
        cell.dateLabel.text = feed.date!
        cell.infoLabel.text = feed.info!
        cell.usernameLabel.text = feed.username!
        cell.singleFeed = feed
        cell.noRecordingLabel.text = feed.noRecordings!
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _chosenIndex = indexPath.row
        _chosenFeed = _feedList[_chosenIndex]
        
        self.performSegue(withIdentifier: "toSingleFeedSegue", sender: self)
    }
        
    @IBAction func moreBtnTapped(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name("toggleSideMenu"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let user = Cache.GetUserInfo()!
        if user.imageRef != userInfo.imageRef! {
            userInfo = user
            DispatchQueue.main.async {
                self.feedTableView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSingleFeedSegue" {
            AudioPlayer.stop()
            if let singleFeedController = segue.destination as? SingleFeedVC {
                singleFeedController.chosenFeed = self._chosenFeed
            }
        }
        
        if segue.identifier == "toCreateAudioSegue" {
            if let createAudioController = segue.destination as? CreateAudioVC {
                createAudioController.sentFromHomePage = true
            }
        }
    }
}
