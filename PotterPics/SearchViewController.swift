//
//  SearchViewController.swift
//  PotterPics
//
//  Created by Suraya Shivji on 12/5/16.
//  Copyright © 2016 Suraya Shivji. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var filteredUsers: [User]!
    var users : [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.delegate = self
        getUsers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getUsers() {
        let DB = FIRDatabase.database().reference()
        let usersRef : FIRDatabaseReference = DB.child("users")
        usersRef.observe(.value, with: { (snapshot) in
            if let dict = snapshot.value as? NSDictionary {
                for item in dict {
                    let json = JSON(item.value)
                    let name: String = json["name"].stringValue
                    let email: String = json["email"].stringValue
                    let fbID: String = json["facebookID"].stringValue
                    let firebaseID: String = item.key as! String
                    let profPicURL: String = json["profPicString"].stringValue
                    let numPosts: Int = json["postCount"].intValue
                    
                    // create User, add to users array
                    let user = User(name: name, email: email, facebookID: fbID, userID: firebaseID, profPic: profPicURL, postCount: numPosts)
                    if let currentID = FIRAuth.auth()?.currentUser?.uid {
                        if(firebaseID != currentID) {
                            self.users.append(user)
                            self.filteredUsers = self.users
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        })
    }
    
    // MARK: - Table View Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // check for nil
        if self.filteredUsers != nil {
            return self.filteredUsers!.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell") as! SearchTableViewCell
        cell.searchImageView.image = UIImage()
        let user = filteredUsers[indexPath.row]
        let name = user.name
        
        let profPicURL = user.profPic
        let url = URL(string: profPicURL)
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!)
            DispatchQueue.main.async {
                var image = UIImage(data: data!)
                image = image?.potter_circle
                cell.searchImageView.contentMode = UIViewContentMode.scaleAspectFill
                cell.searchImageView.image = image
            }
        }
        // set # of posts
        cell.numPostsLabel.text = user.postCount == 1 ? "\(user.postCount) Post" : "\(user.postCount) Posts"
        
        cell.searchName.text = name
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // resign keyboard
        self.searchBar.resignFirstResponder()
        
        let indexPath = self.tableView.indexPathForSelectedRow
        let user = filteredUsers[(indexPath?.row)!]
        
        // go to profile tab
        let data: [String: Int] = ["index": 3]
        let notificationName = Notification.Name("switchTab")
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: data)
        
        let userID: [String: String] = ["id": user.userID]
        let profileName = Notification.Name("loadProfileData")
        NotificationCenter.default.post(name: profileName, object: nil, userInfo: userID)
    }
    // MARK: - Search Bar Methods
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // search bar text changed
        if(searchText.isEmpty) {
            filteredUsers = users
        } else {
            // user typed in search box
            // return true in filter if item should be included
            filteredUsers = users.filter({ (user: User) -> Bool in
                let name = user.name
                if name.range(of: searchText, options: .caseInsensitive ) != nil {
                    return true
                } else {
                    return false
                }
            })
        }
        self.tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
}
