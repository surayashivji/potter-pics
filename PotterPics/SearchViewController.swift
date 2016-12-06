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
        filteredUsers = users
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
                    // create User, add to users array
                    let user = User(name: name, email: email, facebookID: fbID, userID: firebaseID, profPic: profPicURL)
                    self.users.append(user)
                    self.filteredUsers = self.users
                }
            }
        })
    }
    
    // MARK: - Table View Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.filteredUsers != nil { // check for nil
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
                image = image?.circle
                cell.searchImageView.contentMode = UIViewContentMode.scaleAspectFill
                cell.searchImageView.image = image
            }
        }
        cell.searchName.text = name
        cell.searchCountPosts.text = "\(indexPath.row)" // change to number of posts after
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = UITableViewCellSelectionStyle.none
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
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
}

extension UIImage {
    var circle: UIImage? {
        let square = CGSize(width: min(size.width, size.height), height: min(size.width, size.height))
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: square))
        imageView.contentMode = .scaleAspectFill
        imageView.image = self
        imageView.layer.cornerRadius = square.width/2
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}
