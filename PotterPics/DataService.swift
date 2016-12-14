//
//  DataService.swift
//  PotterPics
//
//  Created by Suraya Shivji on 11/29/16.
//  Copyright © 2016 Suraya Shivji. All rights reserved.
//

import UIKit
import Firebase

let DB = FIRDatabase.database().reference()
//let STORAGE = FIRStorage.storage().reference()

class DataService: NSObject {
    
    static let dataService = DataService()
    
    // Database references
    var ref : FIRDatabaseReference = DB
    var refPosts : FIRDatabaseReference = DB.child("posts")
    var refUsers : FIRDatabaseReference = DB.child("users")
    
    // Storage references
    // var REF_POST_IMAGES : FIRStorageReference = STORAGE.child("post-pics")
}
