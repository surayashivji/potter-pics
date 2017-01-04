
//
//  ProfileViewController.swift
//  PotterPics
//
//  Created by Suraya Shivji on 12/6/16.
//  Copyright © 2016 Suraya Shivji. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON
import FBSDKLoginKit
import FBSDKCoreKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var user: FIRUser?
//    var uid: String?
    
    var ref: FIRDatabaseReference! = FIRDatabase.database().reference()
    var posts = [Post]()
    var userName: String!
    var picURL: String!
    
//    var searchUID: String?
    
    @IBOutlet weak var numPostsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var proileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        let stripCol = defaults.colorForKey(key: "navCol")
        self.view.backgroundColor = stripCol
        
        // set the UID so that we know if it's the current user
//        self.searchUID = FIRAuth.auth()?.currentUser?.uid
        if let currentUser = FIRAuth.auth()?.currentUser?.uid {
            configureHeader(currentID: currentUser)
        }
        
        let profileName = Notification.Name("loadProfileData")
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileViewController.loadData(notification:)), name: profileName, object: nil)
    }
    
    func loadData(notification: Notification) {
        print("data loaded")
        // extract user id from notification info
        guard let userID = notification.userInfo else {
            print("no userID given from table view")
            return
        }
        if let id = userID["id"] as? String {
            // reload profile with user's info
            print("reload profile")
            print("\n \(id)")
            configureHeader(currentID: id)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // called the first time the profile tab is selected
        
        // searchUID came from search view controller
//        if self.searchUID != FIRAuth.auth()?.currentUser?.uid {
//            // came from search
//            print("Came from search?")
//            configureHeader(currentID: )
//            getUserPosts()
//        } else {
//            // user's own profile
//            getUserPosts()
//        }
        
        // set num posts
        if posts.count == 1 {
            self.numPostsLabel.text = "\(self.posts.count) Post"
        } else {
            self.numPostsLabel.text = "\(self.posts.count) Posts"
        }
        
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutUser(_ sender: UIButton) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            FBSDKLoginManager().logOut()
            self.dismiss(animated: true, completion: nil)
            
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    func configureHeader(currentID: String) {
//        let uid = self.searchUID
        let uid = currentID
        var profPicURL: String = ""
        var name: String = "Name"
        ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            
            // set name label
            name = value?["name"] as! String
            print("Current name for profile: \(name)")
            self.nameLabel.text = name
            
            profPicURL = value?["profPicString"] as! String
            
            // set image
            if profPicURL.characters.count > 0 {
                let url = URL(string: profPicURL)
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url!)
                    DispatchQueue.main.async {
                        let image = UIImage(data: data!)?.circle
                        self.proileImageView.contentMode = UIViewContentMode.scaleAspectFill
                        self.proileImageView.image = image
                    }
                }
            } else {
                let image = UIImage(named: "default")?.circle
                self.proileImageView.contentMode = UIViewContentMode.scaleAspectFill
                self.proileImageView.image = image
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // MARK: Table View Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as! ProfileTableViewCell
        let post = self.posts[indexPath.row]
        let caption = post.caption
        let uid = post.uid
        let downloadURL = post.downloadURL
        let profPic = self.picURL
        let name = self.userName
        
        // user's name
        cell.nameLabel.text = name
        
        // caption
        cell.captionLabel.text = caption
        
        // profile image
//            let url = URL(string: profPic!)
//            DispatchQueue.global().async {
//                let data = try? Data(contentsOf: url!)
//                DispatchQueue.main.async {
//                    let image = UIImage(data: data!)?.circle
//                    cell.smallProfileImg.contentMode = UIViewContentMode.scaleAspectFill
//                    cell.smallProfileImg.image = image
//                }
//            }
        
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
    
    // MARK: Firebase Query Methods
    
    // get current user's posts
    func getUserPosts() {
//        let uid = self.searchUID
//        let ref = FIRDatabase.database().reference(withPath: "posts").queryOrdered(byChild: "uid").queryEqual(toValue: uid)
//        ref.observeSingleEvent(of: .value, with: { snapshot in
//            self.updatePostCount(numPosts: String(snapshot.childrenCount))
//            if let dict = snapshot.value as? NSDictionary {
//                for item in dict {
//                    
//                    let json = JSON(item.value)
//                    let caption: String = json["caption"].stringValue
//                    let downloadURL: String = json["download_url"].stringValue
//                    
////                    let defaults = UserDefaults.standard
////                    let profPic = defaults.string(forKey: "fbImgURL")
////                    let name = defaults.string(forKey: "userName")
//                    
////                    let name = n
////                    let profPic = self.picURL
//                    
//                    let name: String = json["name"].stringValue
//                    let profPic: String = json["profPicString"].stringValue
//                    
//                    let post = Post(uid: uid!, caption: caption, downloadURL: downloadURL, name: name, profPic: profPic)
//
////                    let post = Post(uid: uid!, caption: caption, downloadURL: downloadURL, name: "Jenny Terando", profPic: "http://graph.facebook.com/1265035910223625/picture?type=large")
//                    self.posts.append(post)
//                    self.tableView.reloadData()
//                }
//            }
//        })
        print("getting posts")
    }

    func updatePostCount(numPosts: String) {
        if(Int(numPosts) == 1) {
            self.numPostsLabel.text = "\(numPosts) Post"
        } else {
            self.numPostsLabel.text = "\(numPosts) Posts"
        }
    }
}
