//
//  User.swift
//  PotterPics
//
//  Created by Suraya Shivji on 12/5/16.
//  Copyright © 2016 Suraya Shivji. All rights reserved.
//

import UIKit

class User {
    var name: String
    var email: String
    var facebookID: String
    var userID: String  // firebase ID
    var profPic: String // fb profile picture
    var postCount: Int
    
    init(name: String, email: String, facebookID: String, userID: String, profPic: String, postCount: Int){
        self.name = name
        self.email = email
        self.facebookID = facebookID
        self.userID = userID
        self.profPic = profPic
        self.postCount = postCount
    }
}
