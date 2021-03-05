//
//  ProfileVC.swift
//  AudioStories
//
//  Created by Ahmed Jeylani on 25/04/2020.
//  Copyright © 2020 Jeylani Technologies. All rights reserved.
//

import UIKit
import Firebase

class ProfileVC: BaseVC, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var profileImageView: CustomDefaultUIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailAddressLabel: UILabel!
    @IBOutlet weak var feedTableView: UITableView!
    @IBOutlet weak var addStoryBtn: CustomRoundUIButton!
    @IBOutlet weak var emptyStateView: UIView!
    
    var _feedList = [Feed]()
    let _cellId = "cellId"
    var _chosenIndex = 0
    var _chosenFeed:Feed = Feed()
    var _databaseRef:DatabaseReference!
    var _cachedDeleteItem:Feed!
    var _navigatingToAnotherPage = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Utilities.setNavigationBar(sender: self)
        // Next two lines hides bar below navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        let editProfileButton = UIButton()
        editProfileButton.setTitle("Edit", for: .normal)
        editProfileButton.setTitleColor(UIColor(named: "accent"), for: .normal)
        // btn1.frame = CGRectMake(0, 0, 30, 30)
        editProfileButton.addTarget(self, action: #selector(editProfilePressed), for: .touchUpInside)
        self.navigationItem.setRightBarButton(UIBarButtonItem(customView: editProfileButton), animated: true);
        
        feedTableView.separatorInset = UIEdgeInsets.zero

        let fAuth = Auth.auth()
        
        if let user = fAuth.currentUser {
            emailAddressLabel.text = user.email
        }
        
        feedTableView.delegate = self;
        feedTableView.dataSource = self;
        
        _databaseRef = Database.database().reference()
        
        profileImageView.loadImageUsingCache(feedId: nil, uniqueId: userInfo.uniqueID!, contentMode: .scaleAspectFit)
        usernameLabel.text = userInfo.username
        
        listOfFeedEvents()
        Utilities.showEmptyStateOrList(emptyStateView: emptyStateView, tableView: feedTableView, addStoryBtn: addStoryBtn, list: _feedList)
    }
    
    func listOfFeedEvents() {
        
        let feedRef = _databaseRef.child(DatabaseStringReference.FEED_REF)
        // This runs once and goes for all children under events!
        feedRef.observe(.childAdded, with: { (dataSnapshot) in
            if let dictionary = dataSnapshot.value as? [String: AnyObject] {
                let singleFeed = Feed()
                singleFeed.setValuesForKeys(dictionary)
                
                if let id = singleFeed.creatorID {
                    if id == self.userInfo.uniqueID {
                        self._feedList.insert(singleFeed, at: 0)
                    }
                }
                
                // This will crash because of background thread, therefore run an async task
                DispatchQueue.main.async {
                    self.feedTableView.reloadData()
                }
                Utilities.showEmptyStateOrList(emptyStateView: self.emptyStateView, tableView: self.feedTableView, addStoryBtn: self.addStoryBtn, list: self._feedList)
            }
        })
        
        feedRef.observe(.childChanged, with: { (dataSnapshot) in
            if let dictionary = dataSnapshot.value as? [String: AnyObject] {
                let singleFeed = Feed()
                singleFeed.setValuesForKeys(dictionary)

                let feedIndex = self._feedList.firstIndex(where: {$0.uniqueID == singleFeed.uniqueID})
                
                if let id = singleFeed.creatorID {
                    if id == self.userInfo.uniqueID {
                        if let index = feedIndex {
                            self._feedList[index].noRecordings = singleFeed.noRecordings
                        }
                    }
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
                Utilities.showEmptyStateOrList(emptyStateView: self.emptyStateView, tableView: self.feedTableView, addStoryBtn: self.addStoryBtn, list: self._feedList)
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
        cell.profileImage.loadImageUsingCache(feedId: feed.uniqueID, uniqueId: feed.creatorID!, contentMode: .redraw)
        
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "Warning", message: "This will permanently delete this story. Are you sure you want to continue?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default) { (_) in
                self._cachedDeleteItem = self._feedList[indexPath.row]
                
                self._databaseRef.child(DatabaseStringReference.FEED_REF).child(self._cachedDeleteItem.uniqueID!).setValue(nil)
                self._databaseRef.child(DatabaseStringReference.STORIES_REF).child(self._cachedDeleteItem.uniqueID!).setValue(nil)
                let audioStorageRef = Storage.storage().reference().child(DatabaseStringReference.AUDIO_STORY_STORAGE_REF)
                audioStorageRef.child(self._cachedDeleteItem.fileName!).delete { (error) in
                    if let error = error {
                        print("Error Deleting image: " + error.localizedDescription)
                    } else {
                        print("Succesfully deleted audio story")
                    }
                }
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(yesAction)
            self.present(alert, animated: true, completion: nil)
        
        }
    }
    
    @objc func editProfilePressed() {
        self.performSegue(withIdentifier: "toEditProfileSegue", sender: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if !_navigatingToAnotherPage {
            self.navigationController?.isToolbarHidden = true // This is the bottom bar
            self.navigationController?.navigationBar.isHidden = true
        } else {
            _navigatingToAnotherPage = false
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSingleFeedSegue" {
            AudioPlayer.stop()
            _navigatingToAnotherPage = true
            if let singleFeedController = segue.destination as? SingleFeedVC {
                singleFeedController.chosenFeed = self._chosenFeed
            }
        }
        
        if segue.identifier == "toCreateAudioSegue" {
            if let createAudioController = segue.destination as? CreateAudioVC {
                _navigatingToAnotherPage = true
                createAudioController.sentFromHomePage = true
            }
        }
        
        if segue.identifier == "toEditProfileSegue" {
            if let _ = segue.destination as? EditProfileVC {
                _navigatingToAnotherPage = true
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let user = Cache.GetUserInfo()!
        if user.imageRef != userInfo.imageRef! {
            userInfo = user
            profileImageView.loadImageUsingCache(feedId: nil, uniqueId: userInfo.uniqueID!, contentMode: .scaleAspectFit)
            DispatchQueue.main.async {
                self.feedTableView.reloadData()
            }
        }
    }
}
