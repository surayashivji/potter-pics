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
//    var profPic: String // filename string
    var facebookID: String
    var userID: String  // firebase ID
    
    
    init(name: String, email: String, facebookID: String, userID: String){
        self.name = name
        self.email = email
//        self.profPic = profPic
        self.facebookID = facebookID
        self.userID = userID
    }   
}
