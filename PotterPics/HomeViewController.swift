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
            // user logged in, segue to main feed
            let graphRequest:FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"first_name,email, picture.type(large)"])
            
            graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                
                if ((error) != nil)
                {
                    print("Error: \(error)")
                }
                else
                {
                    let data:[String:AnyObject] = result as! [String : AnyObject]
                    print(data)
                    
                }
            })
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
                            print("error")
                            print(error)
                        } else {
                            print("success")
                            
                            self.dismiss(animated: true, completion: nil)
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
    
