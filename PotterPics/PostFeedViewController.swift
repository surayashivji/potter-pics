//
//  PostFeedViewController.swift
//  PotterPics
//
//  Created by Suraya Shivji on 12/7/16.
//  Copyright © 2016 Suraya Shivji. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON
import FBSDKLoginKit
import FBSDKCoreKit
import MBProgressHUD
import AFNetworking

class PostFeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var feedTableView: UITableView!

    var feeds = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // get posts for all users
        getAllPosts(refreshing: false, refreshControl: nil)
        
        // refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        self.feedTableView.insertSubview(refreshControl, at: 0)
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        getAllPosts(refreshing: true, refreshControl: refreshControl)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Table View Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.feeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell", for: indexPath) as! PostFeedTableViewCell
        let post = self.feeds[indexPath.row]
        let caption = post.caption
        let downloadURL = post.downloadURL
        let profPic = post.profPic
        let name = post.name
        let date = post.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        // user's name
        cell.nameLabel.text = name
        
        // caption
        cell.captionLabel.text = caption
        
        // post image
        cell.postImage.image = nil
        if let postURL = URL(string: downloadURL) {
            let postRequest = URLRequest(url: postURL)
            cell.postImage.setImageWith(postRequest, placeholderImage: nil, success:
                { (imageRequest, imageResponse, image) in
                    cell.postImage.contentMode = UIViewContentMode.scaleToFill
                    cell.postImage.image = image
            }, failure: { (imageRequest, imageResponse, error) -> Void in
                // failure downloading image
                print("Error downloading Firebase post image")
                print(error)
            })
        }
        
        // profile image
        cell.smallProfileImg.image = nil
        if let url = URL(string: profPic) {
            let profileRequest = URLRequest(url: url)
            cell.smallProfileImg.setImageWith(profileRequest, placeholderImage: nil, success:
                { (imageRequest, imageResponse, image) in
                    cell.smallProfileImg.image = image.potter_circle
            }, failure: { (imageRequest, imageResponse, error) -> Void in
                // failure downloading image
                print("Error downloading Firebase profile image for feed/")
                print(error)
            })
        }
        
        // set date of post
        cell.dateLabel.text = dateString
        
        return cell
    }
    
    // MARK: Queries
    func getAllPosts(refreshing: Bool, refreshControl: UIRefreshControl?) {
        let ref = FIRDatabase.database().reference(withPath: "posts")
        MBProgressHUD.showAdded(to: self.view, animated: true)
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if let dict = snapshot.value as? NSDictionary {
                if self.feeds.count == Int(snapshot.childrenCount) {
                    if refreshing {
                        refreshControl?.endRefreshing()
                    }
                    MBProgressHUD.hide(for: self.view, animated: true)
                    return
                }
                self.feeds = []
                for item in dict {
                    let json = JSON(item.value)
                    let uid = json["uid"].stringValue
                    var name: String = ""
                    var pic: String = ""
                    let caption: String = json["caption"].stringValue
                    let downloadURL: String = json["download_url"].stringValue
                    let timestamp = json["timestamp"].doubleValue
                    let date = Date(timeIntervalSince1970: timestamp/1000)
                    
                    let usersReference = FIRDatabase.database().reference(withPath: "users").queryOrderedByKey().queryEqual(toValue: uid)
                    usersReference.observeSingleEvent(of: .value, with: { snapshot in
                        if let dict = snapshot.value as? NSDictionary {
                            let userInfo = dict.allValues[0]
                            let userJSON = JSON(userInfo)
                            name = userJSON["name"].stringValue
                            pic = userJSON["profPicString"].stringValue
                        }
                        let post = Post(uid: uid, caption: caption, downloadURL: downloadURL, name: name, profPic: pic, date: date)
                        self.feeds.append(post)
                        
                        // sort posts by date
                        self.feeds.sort{$0.date.compare($1.date) == .orderedDescending}
                        self.feedTableView.reloadData()
                    })
                }
            }
            if refreshing {
                refreshControl?.endRefreshing()
            }
            MBProgressHUD.hide(for: self.view, animated: true)
        })
    }
}
