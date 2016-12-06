//
//  FacebookService.swift
//  PotterPics
//
//  Created by Suraya Shivji on 12/4/16.
//  Copyright © 2016 Suraya Shivji. All rights reserved.
//

import UIKit
import FBSDKShareKit
import FBSDKLoginKit
import FBSDKCoreKit

class FacebookService: NSObject {
    
    // name, email, fb id
    func getBasicInfo() -> [String: NSString] {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"])
        var values : [String: NSString] = [:]
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            
            if ((error) != nil) {
                // Process error
                print("Error: \(error)")
            } else {
                let data:[String:AnyObject] = result as! [String : AnyObject]
                
                let userName:NSString = data["name"] as! NSString
                let userEmail:NSString = data["email"] as! NSString
                let userID:NSString = data["id"] as! NSString
                
                print("Users Facebook ID is: \(userID)")
                
                values = ["name": userName, "email": userEmail, "facebookID": userID] as [String: NSString]
            }
        })
        return values
    }
}
