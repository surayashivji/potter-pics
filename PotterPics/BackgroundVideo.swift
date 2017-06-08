//
//  BackgroundVideo.swift
//
// Adapted From https://github.com/Guzlan/BackgroundVideoiOS

import Foundation
import AVKit
import AVFoundation

enum BackgroundVideoErrors: Error {
    case invalidVideo
}

class BackgroundVideo {
    // creating an instance of an AVPlayer for background video
    var backGroundPlayer : AVPlayer?
    var videoURL: URL?
    var viewController: UIViewController?
    var hasBeenUsed: Bool = false

    init (on viewController: UIViewController, withVideoURL URL: String) {
        self.viewController = viewController
        
        // parse the video string to split it into name and extension
        let videoNameAndExtension:[String]? = URL.characters.split{$0 == "."}.map(String.init)
        if videoNameAndExtension!.count == 2 {
            if let videoName = videoNameAndExtension?[0] , let videoExtension = videoNameAndExtension?[1] {
                if let url = Bundle.main.url(forResource: videoName, withExtension: videoExtension) {
                    self.videoURL = url
                    // initialize our player with our fetched video url
                    self.backGroundPlayer = AVPlayer(url: self.videoURL!)
                } else {
                    print(BackgroundVideoErrors.invalidVideo)
                }
            }
        } else {
            print("Wrong video name format")
        }
    }
    
    deinit{
        if self.hasBeenUsed {
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
            NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil)
        }
    }
    
    /*
     setUpBackground called in viewDidLoad to load a local video to play as the background
     */
    func setUpBackground() {
        self.backGroundPlayer?.actionAtItemEnd = .none
        
        // add the video to your view
        let loginView: UIView = self.viewController!.view // get our view controllers view
        let playerLayer = AVPlayerLayer(player: self.backGroundPlayer)
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill // preserve aspect ratio and resize to fill screen
        playerLayer.zPosition = -1 // set it's position behined anything in our view
        playerLayer.frame = loginView.frame // set our player frame to our view's frame
        loginView.layer.addSublayer(playerLayer)
        
        self.backGroundPlayer?.play() // start the video
        self.hasBeenUsed = true
    
    }
    
    // A function that will restarts the video for the purpose of looping
   @objc private func loopVideo() {
        self.backGroundPlayer?.seek(to: kCMTimeZero)
        self.backGroundPlayer?.play()
    }
    
    // play/pause video
    func pause() {
        self.backGroundPlayer?.pause()
    }

    func play() {
        self.backGroundPlayer?.play()
        
    }
}
