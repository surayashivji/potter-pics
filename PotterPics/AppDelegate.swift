//
//  AppDelegate.swift
//  PotterPics
//
//  Created by Suraya Shivji on 11/16/16.
//  Copyright © 2016 Suraya Shivji. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FIRApp.configure()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var initialViewController = UIViewController()
        if launchedBefore  {
            // app has been launched before, segue to login
            print("Not first launch.")
            initialViewController = storyboard.instantiateViewController(withIdentifier: "homeView") as! HomeViewController

        } else {
            // app has not been launched before, segue to house quiz to set defaults
            print("First launch, setting the UserDefault.")
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            initialViewController = storyboard.instantiateViewController(withIdentifier: "houseQuiz") as! QuizViewController
        }
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()

        return true
    }  
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let handled  = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        return handled
        
    }
}

