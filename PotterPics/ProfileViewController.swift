
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
import AFNetworking
import MBProgressHUD

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var user: User?
    var ref: FIRDatabaseReference! = FIRDatabase.database().reference()
    var posts = [Post]()
    typealias CompletionHandler = (_ success:Bool) -> Void
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var returnButton: UIButton!
    @IBOutlet weak var houseCrest: UIImageView!
    @IBOutlet weak var numPostsLabel: UILabel!
    @IBOutlet weak var returnView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var proileImageView: UIImageView!
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        let stripCol = defaults.potter_colorForKey(key: "navCol")
        self.view.backgroundColor = stripCol
        
        // set the UID so that we know if it's the current user
        if let currentUser = FIRAuth.auth()?.currentUser?.uid {
            configureHeader(currentID: currentUser, completionHandler: { (success) -> Void in
                if success {
                    // header success
                    self.getUserPosts(currentID: currentUser, refreshing: false, refreshControl: nil)
                } else {
                    // header fail
                    print("Failure downloading header!")
                }
            })
        }
        
        let profileName = Notification.Name("loadProfileData")
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileViewController.loadData(notification:)), name: profileName, object: nil)
        
        // refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        self.tableView.insertSubview(refreshControl, at: 0)
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        getUserPosts(currentID: self.user?.userID, refreshing: true, refreshControl: refreshControl)
    }
    
    func loadData(notification: Notification) {
        // extract user id from notification info
        self.posts.removeAll()
        self.tableView.reloadData()
        guard let userID = notification.userInfo else {
            return
        }
        if let id = userID["id"] as? String {
            // reload profile with user's info
            let defaults = UserDefaults.standard
            let navigationColor = defaults.potter_colorForKey(key: "navCol")
            self.returnView.backgroundColor = navigationColor
            self.returnView.isHidden = false
            // hide logout button
            self.logoutButton.isHidden = true
            configureHeader(currentID: id, completionHandler: { (success) -> Void in
                if success {
                    // header success
                    self.getUserPosts(currentID: id, refreshing: false, refreshControl: nil)
                } else {
                    // download fail
                    print("Failure setting up header")
                }
            })
        }
    }
    
    @IBAction func returnToProfile(_ sender: Any) {
        self.logoutButton.isHidden = false
        if let currentUser = FIRAuth.auth()?.currentUser?.uid {
            configureHeader(currentID: currentUser,  completionHandler: { (success) -> Void in
                if success {
                    // header success
                    self.posts.removeAll()
                    self.tableView.reloadData()
                    self.getUserPosts(currentID: currentUser, refreshing: false, refreshControl: nil)
                } else {
                    // download fail
                    print("Failure to load header info")
                }
            })
            self.returnView.isHidden = true
        }
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
    
    func configureHeader(currentID: String, completionHandler: @escaping CompletionHandler) {
        let uid = currentID
        var profPicURL: String = ""
        var name: String = "Name"
        var email: String = "Email"
        var fbID: String = ""
        var flag: Bool = false
        var postCount: Int = 0
        ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            // extract values
            name = value?["name"] as! String
            profPicURL = value?["profPicString"] as! String
            email = value?["email"] as! String
            fbID = value?["facebookID"] as! String
            postCount = value?["postCount"] as! Int
            
            // user: name, email, facebookID, userID, profPic, postCount
            self.user = User(name: name, email: email, facebookID: fbID, userID: currentID, profPic: profPicURL, postCount: postCount)
            
            // set name label
            self.nameLabel.text = name
            
            // set image
            if profPicURL.characters.count > 0 {
                let url = URL(string: profPicURL)
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url!)
                    DispatchQueue.main.async {
                        let image = UIImage(data: data!)?.potter_circle
                        self.proileImageView.contentMode = UIViewContentMode.scaleAspectFill
                        self.proileImageView.image = image
                    }
                }
            } else {
                let image = UIImage(named: "default")?.potter_circle
                self.proileImageView.contentMode = UIViewContentMode.scaleAspectFill
                self.proileImageView.image = image
            }
            
            // set house crest
            let house = value?["house"] as! String
            let image = "\(house).png"
            self.houseCrest.image = UIImage(named: image)
            
            // set num posts
            if postCount == 1 {
                self.numPostsLabel.text = "\(postCount) Post"
            } else {
                self.numPostsLabel.text = "\(postCount) Posts"
            }
            flag = true
            completionHandler(flag)
        }) { (error) in
            flag = false
            completionHandler(flag)
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
        let downloadURL = post.downloadURL
        let profPic = self.user?.profPic
        let name = self.user?.name
        
        let date = post.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        // user's post image
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
        
        // user's name
        cell.nameLabel.text = name
        
        // user's post caption
        cell.captionLabel.text = caption
        
        // profile image
        if let urlString = profPic {
            if let picUrl = URL(string: urlString) {
                let placeholder = UIImage(named: "default")
                let profileRequest = URLRequest(url: picUrl)
                cell.smallProfileImg.setImageWith(profileRequest, placeholderImage: placeholder,
                success:
                    { (imageRequest, imageResponse, image) in
                        cell.smallProfileImg.image = image.potter_circle
                }, failure: { (imageRequest, imageResponse, error) -> Void in
                    // failure downloading image
                    print("Error downloading Firebase profile image")
                    print(error)
                })
            }
        }
        
        // date
        cell.dateLabel.text = dateString
        
        return cell
    }
    
    // MARK: Firebase Query Methods
    
    // get current user's posts
    func getUserPosts(currentID: String?, refreshing: Bool, refreshControl: UIRefreshControl?) {
        if let uid = currentID {
           let ref = FIRDatabase.database().reference(withPath: "posts").queryOrdered(byChild: "uid").queryEqual(toValue: uid)
            
            MBProgressHUD.showAdded(to: self.view, animated: true)
            
            var postsCount = self.posts.count
            
            ref.observeSingleEvent(of: .value, with: { snapshot in
                if let dict = snapshot.value as? NSDictionary {
                    if self.posts.count == Int(snapshot.childrenCount) {
                        if refreshing {
                            refreshControl?.endRefreshing()
                        }
                        MBProgressHUD.hide(for: self.view, animated: true)
                        return
                    }
                    postsCount = Int(snapshot.childrenCount)
                    self.posts = []
                    for item in dict {
                        let json = JSON(item.value)
                        let caption: String = json["caption"].stringValue
                        let downloadURL: String = json["download_url"].stringValue
                        let name: String = json["name"].stringValue
                        let profPic: String = json["profPicString"].stringValue
                        let timestamp = json["timestamp"].doubleValue
                        
                        let date = Date(timeIntervalSince1970: timestamp/1000)
                        
                        // create post from firebase data
                        let post = Post(uid: uid, caption: caption, downloadURL: downloadURL, name: name, profPic: profPic, date: date)
                        self.posts.append(post)
                    }
                    // sort posts by timestamp
                    self.posts.sort{$0.date.compare($1.date) == .orderedDescending}
                    self.tableView.reloadData()
                }
                if refreshing {
                    // update post count
                    if postsCount == 1 {
                        self.numPostsLabel.text = "\(postsCount) Post"
                    } else {
                        self.numPostsLabel.text = "\(postsCount) Posts"
                    }
                    refreshControl?.endRefreshing()
                }
                MBProgressHUD.hide(for: self.view, animated: true)
            })
        }
    }
}
