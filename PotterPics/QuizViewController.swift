//
//  QuizViewController.swift
//  PotterPics
//
//  Created by Suraya Shivji on 11/28/16.
//  Copyright © 2016 Suraya Shivji. All rights reserved.
//

import UIKit

class QuizViewController: UIViewController {

    var house : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func submitQuiz() {
        let defaults = UserDefaults.standard
        defaults.set(self.house, forKey: "userHouse")
        defaults.synchronize()
        
        // notify user of house with Confetti
        // https://github.com/learn-co-curriculum/swift-podsConfetti-lab
        
        // dismiss quiz view controller (modal)
        
        // segue to home for login
    }
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
