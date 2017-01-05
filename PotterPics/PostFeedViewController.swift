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

class PostFeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var feedTableView: UITableView!
    
    var user: FIRUser?
    var uid: String?
    var feeds = [Post]()
    var userName: String!
    var picURL: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = ColorPalette.white
        user = FIRAuth.auth()?.currentUser
        uid = user?.uid
        getAllPosts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.feedTableView.reloadData()
    }
    
    // MARK: Table View Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.feeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PostFeedTableViewCell
        let post = self.feeds[indexPath.row]
        let caption = post.caption
        let uid = post.uid
        let downloadURL = post.downloadURL
        let profPic = post.profPic
        let name = post.name
        
        // user's name
        cell.nameLabel.text = name
        
        // caption
        cell.captionLabel.text = caption
        
        // profile image
        let url = URL(string: profPic)
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!)
            DispatchQueue.main.async {
                let image = UIImage(data: data!)?.circle
                cell.smallProfileImg.contentMode = UIViewContentMode.scaleAspectFill
                cell.smallProfileImg.image = image
            }
        }
        
        // post image
        let postURL = URL(string: downloadURL)
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: postURL!)
            DispatchQueue.main.async {
                let image = UIImage(data: data!)
                cell.postImage.contentMode = UIViewContentMode.scaleAspectFill
                cell.postImage.image = image
            }
        }
        return cell
    }
    
    // MARK: Queries
    func getAllPosts() {
        let uid = FIRAuth.auth()?.currentUser?.uid
        let ref = FIRDatabase.database().reference(withPath: "posts")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            print("COUNT \(snapshot.childrenCount)")
            if let dict = snapshot.value as? NSDictionary {
                for item in dict {
                    let json = JSON(item.value)
                    let uid = json["uid"].stringValue
                    self.getInfo(id: uid)
                    let caption: String = json["caption"].stringValue
                    let downloadURL: String = json["download_url"].stringValue
                    let name = self.userName
                    let profPic = self.picURL
                    let post = Post(uid: uid, caption: caption, downloadURL: downloadURL, name: "Jenny Terando", profPic: "http://graph.facebook.com/1265035910223625/picture?type=large")
                    self.feeds.append(post)
                    self.feedTableView.reloadData()
                }
            }
        })
    }
    
    
    func getInfo(id: String) {
        let usersReference = FIRDatabase.database().reference(withPath: "users").queryOrderedByKey().queryEqual(toValue: id)
        usersReference.observeSingleEvent(of: .value, with: { snapshot in
            if let dict = snapshot.value as? NSDictionary {
                for item in dict {
                    let json = JSON(item.value)
                    let name: String = json["name"].stringValue
                    self.userName = name
                    let pic: String = json["profPicString"].stringValue
                    self.picURL = pic
                }
            }
        })
    }
    
}
