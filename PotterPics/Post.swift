//
//  Post.swift
//  PotterPics
//
//  Created by Suraya Shivji on 12/7/16.
//  Copyright © 2016 Suraya Shivji. All rights reserved.
//

import UIKit

class Post {
    var uid: String  // firebase ID
    var caption: String
    var downloadURL: String
    var name: String
    var profPic: String // facebook profile picture
    var date: Date
    
    init(uid: String, caption: String, downloadURL: String, name: String, profPic: String, date: Date){
        self.uid = uid
        self.caption = caption
        self.downloadURL = downloadURL
        self.name = name
        self.profPic = profPic
        self.date = date
    }
}
