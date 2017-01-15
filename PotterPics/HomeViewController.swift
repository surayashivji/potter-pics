//
//  HomeViewController.swift
//  PotterPics
//
//  Created by Suraya Shivji on 11/16/16.
//  Copyright © 2016 Suraya Shivji. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import FBSDKCoreKit

class HomeViewController: UIViewController {
    
    var cloudsVideo: BackgroundVideo?
    let facebookPermissions = ["public_profile", "email", "user_friends"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set up background video
        self.cloudsVideo = BackgroundVideo(on: self, withVideoURL: "IntroMusic.mp4")
        self.cloudsVideo?.setUpBackground()
    }
    
    // login user via Facebook
    @IBAction func loginTapped(_ sender: HomeButton) {
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        // check that the user isn't already logged in
        if FBSDKAccessToken.current() != nil {
            // user logged in, segue to navigation controller
            self.cloudsVideo?.pause()
            self.performSegue(withIdentifier: "mainNavSegue", sender: nil)
        } else {
            loginManager.logIn(withReadPermissions: self.facebookPermissions, from: self, handler: { (result, error) in
                if (error != nil) {
                    loginManager.logOut()
                    let message: String = "An error has occured. \(error)"
                    let alertView = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
                    alertView.addAction(UIAlertAction(title: "Ok ", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alertView, animated: true, completion: nil)
                } else if (result?.isCancelled)! {
                    // user cancelled login
                    loginManager.logOut()
                } else {
                    let accessToken = FBSDKAccessToken.current()
                    guard let accessTokenString = accessToken?.tokenString else { return }
                    let credential = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
                    
                    FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                        if (error != nil) {
                            // handle error
                            print(error ?? "Error")
                        } else {
                            let ref = FIRDatabase.database().reference(fromURL: "https://potterpics-2bcbc.firebaseio.com")
                            
                            // guard for user id
                            guard let uid = user?.uid else {
                                return
                            }
                            let usersReference = ref.child("users").child(uid)
                            
                            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"])
                            graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                                if ((error) != nil) {
                                    // Process error
                                    print("Error: \(error)")
                                } else {
                                    let data: [String:AnyObject] = result as! [String:AnyObject]
                                    
                                    let userName:String = data["name"] as! String
                                    let userEmail:String = data["email"] as! String
                                    let userID:String = data["id"] as! String
                                    let imgURLString = "http://graph.facebook.com/\(userID)/picture?type=large" as String
        
                                    let defaults = UserDefaults.standard
                                    let houseValue = defaults.string(forKey: "userHouse")! as String
                                    
                                    // initial # posts = 0
                                    let values = ["name": userName, "email": userEmail, "facebookID": userID, "profPicString": imgURLString, "house": houseValue, "postCount": 4] as [String : Any]
                                    
                                    // update database with new user
                                    usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                                        // error in database save
                                        if err != nil {
                                            print(err ?? "Error saving user to database")
                                            return
                                        }
                                    })
                                }
                            })
                            self.dismiss(animated: false, completion: nil)
                            self.performSegue(withIdentifier: "mainNavSegue", sender: nil)
                        }
                    }
                }
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
