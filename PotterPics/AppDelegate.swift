
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
        let defaults = UserDefaults.standard
        if launchedBefore  {
            // app has been launched before, segue to login
            let houseValue = defaults.string(forKey: "userHouse")
                var navCol = UIColor()
                switch houseValue! {
                case "Gryffindor":
                    navCol = Gryffindor.navigation
                    break
                case "Slytherin":
                    navCol = Slytherin.navigation
                    break
                case "Hufflepuff":
                    navCol = Hufflepuff.navigation
                    break
                case "Ravenclaw":
                    navCol = Ravenclaw.navigation
                    break
                default:
                    break
            }
            defaults.potter_setColor(color: navCol, forKey: "navCol")
            initialViewController = storyboard.instantiateViewController(withIdentifier: "homeView") as! HomeViewController

        } else {
            // app has not been launched before, segue to house quiz to set defaults
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            UserDefaults.standard.set(true, forKey: "pickHouse")
            let randomNum:UInt32 = arc4random_uniform(4)
            let houses = ["Slytherin", "Gryffindor", "Hufflepuff", "Ravenclaw"]
            let defaults = UserDefaults.standard
            let randomHouse = houses[Int(randomNum)]
            defaults.set(randomHouse, forKey: "userHouse")
            defaults.synchronize()
            var navCol = UIColor()
            switch randomHouse {
            case "Gryffindor":
                navCol = Gryffindor.navigation
                break
            case "Slytherin":
                navCol = Slytherin.navigation
                break
            case "Hufflepuff":
                navCol = Hufflepuff.navigation
                break
            case "Ravenclaw":
                navCol = Ravenclaw.navigation
                break
            default:
                break
            }
            defaults.potter_setColor(color: navCol, forKey: "navCol")
            initialViewController = storyboard.instantiateViewController(withIdentifier: "homeView") as! HomeViewController
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

