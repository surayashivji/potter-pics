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
    var uid: String?
    var ref: FIRDatabaseReference! = FIRDatabase.database().reference()
    var posts = [Post]()
    var userName: String!
    var picURL: String!
    @IBOutlet weak var numPostsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var proileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        let stripCol = defaults.colorForKey(key: "navCol")
        self.view.backgroundColor = stripCol
        user = FIRAuth.auth()?.currentUser
        uid = user?.uid
        configureHeader()
        getUserPosts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    @IBAction func logoutUser(_ sender: UIButton) {
        let firebaseAuth = FIRAuth.auth()
        do {
            print("signing out")
            try firebaseAuth?.signOut()
            FBSDKLoginManager().logOut()
            self.dismiss(animated: true, completion: nil)
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    func configureHeader() {
        let uid = self.uid
        var profPicURL: String = ""
        var name: String = "Name"
        ref.child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            // set name label
            name = value?["name"] as! String
            self.userName = name
            self.nameLabel.text = self.userName
            
            profPicURL = value?["profPicString"] as! String
            self.picURL = profPicURL
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
        // set num posts
        if posts.count == 1 {
            self.numPostsLabel.text = "\(self.posts.count) Post"
        } else {
            self.numPostsLabel.text = "\(self.posts.count) Posts"
        }
    }
    
    
    func generateImage(urlString: String) -> UIImage? {
        let url = URL(string: urlString)
        var image: UIImage = UIImage()
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!)
            DispatchQueue.main.async {
                image = UIImage(data: data!)!
            }
        }
        return image
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
        let profPic = post.profPic
        let name = self.userName
        
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
    
    // MARK: Firebase Query Methods
    
    // get current user's posts
    func getUserPosts() {
        let uid = FIRAuth.auth()?.currentUser?.uid
        let ref = FIRDatabase.database().reference(withPath: "posts").queryOrdered(byChild: "uid").queryEqual(toValue: uid)
        ref.observeSingleEvent(of: .value, with: { snapshot in
//            print(snapshot.childrenCount)
            self.updatePostCount(numPosts: String(snapshot.childrenCount))
            if let dict = snapshot.value as? NSDictionary {
                for item in dict {
                    
                    let json = JSON(item.value)
                    let caption: String = json["caption"].stringValue
                    let downloadURL: String = json["download_url"].stringValue
                    let name = self.userName
                    let profPic = self.picURL
                    let post = Post(uid: uid!, caption: caption, downloadURL: downloadURL, name: name!, profPic: profPic!)
                    self.posts.append(post)
                    self.tableView.reloadData()
                }
            }

        })
    }

    func updatePostCount(numPosts: String) {
        if(Int(numPosts) == 1) {
            self.numPostsLabel.text = "\(numPosts) Post"
        } else {
            self.numPostsLabel.text = "\(numPosts) Posts"
        }
    }

}
