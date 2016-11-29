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
        
        for family in UIFont.familyNames {
            print("\(family)")
            
            for name in UIFont.fontNames(forFamilyName: family) {
                print("   \(name)")
            }
        }
    }
    
    // login user via Facebook
    @IBAction func loginTapped(_ sender: HomeButton) {
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        // check that the user isn't already logged in
        if FBSDKAccessToken.current() != nil {
            // user logged in, segue to navigation controller
            print("User already logged in")
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
                            print("Successful Login")
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
