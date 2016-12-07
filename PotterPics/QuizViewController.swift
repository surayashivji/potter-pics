//
//  QuizViewController.swift
//  PotterPics
//
//  Created by Suraya Shivji on 11/28/16.
//  Copyright © 2016 Suraya Shivji. All rights reserved.
//

import UIKit
import SAConfettiView

class QuizViewController: UIViewController {
    
    @IBOutlet weak var houseCrest: UIImageView!
    @IBOutlet weak var bg: UIImageView!
    @IBOutlet weak var pickButton: HomeButton!
    var house : String?
    var confettiView: SAConfettiView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.confettiView = SAConfettiView(frame: self.view.bounds)
        self.confettiView.type = .Confetti
        self.confettiView.intensity = 1
        self.houseCrest.alpha = 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func pickHouse(_ sender: Any) {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.pickButton.isHidden = true
            self.bg.isHidden = true
        })
        
        // set house
        self.house = randomizeHouse()
        
        // make confetti based on house
        configureConfetti()
        
        let image = UIImage(named: self.house!)
        // animate crest in
        self.houseCrest.image = image
        UIView.animate(withDuration: 0.3, animations: {
            self.houseCrest.alpha = 1
        })
        
        // persist user's house
        let defaults = UserDefaults.standard
        defaults.set(self.house, forKey: "userHouse")
        defaults.synchronize()
        
        let when = DispatchTime.now() + 3 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            UIView.animate(withDuration: 0.5, animations: { 
                self.confettiView.stopConfetti()
                self.houseCrest.alpha = 0.6
            })
            self.dismiss(animated: false, completion: nil)
            self.performSegue(withIdentifier: "backFromHouse", sender: nil)
        }
    }
    
    
    // pick a random house for the user
    func randomizeHouse() -> String {
        let randomNum:UInt32 = arc4random_uniform(4)
        let houses = ["Slytherin", "Gryffindor", "Hufflepuff", "Ravenclaw"]
        return houses[Int(randomNum)]
    }
    
    // configure the confetti based on the user's house's colors
    func configureConfetti()
    {
        switch self.house! {
        case "Gryffindor":
            self.confettiView.colors = [Gryffindor.red, Gryffindor.brightYellow, Gryffindor.darkRed]
            break
        case "Slytherin":
            self.confettiView.colors = [Slytherin.darkGreen, Slytherin.green, Slytherin.lightGray, Slytherin.darkGray]
            break
        case "Hufflepuff":
            self.confettiView.colors = [Hufflepuff.lightYellow, Hufflepuff.muskyBrown, Hufflepuff.solidYellow, Hufflepuff.darkBrown]
            break
        case "Ravenclaw":
            self.confettiView.colors = [Ravenclaw.blue, Ravenclaw.darkBlue, Ravenclaw.brown, Ravenclaw.gray]
            break
        default:
            break
        }
        self.view.addSubview(self.confettiView)
        self.confettiView.startConfetti()
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
}
