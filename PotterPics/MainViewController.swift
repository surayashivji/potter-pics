//
//  MainViewcontroller.swift
//  PotterPics
//
//  Created by Suraya Shivji on 11/27/16.
//  Copyright © 2016 Suraya Shivji. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, TabBarDelegate   {
    
    //MARK: Properties
    var navColor: UIColor!
    var views = [UIView]()
    let items = ["Feed", "Search", "Post", "Profile"]
    var viewsAreInitialized = false
    lazy var collectionView: UICollectionView  = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let cv: UICollectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: (self.view.bounds.height)), collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = UIColor.blue
        cv.bounces = false
        cv.isPagingEnabled = true
        cv.isDirectionalLockEnabled = true
        return cv
    }()
    
    lazy var tabBar: TabBar = {
        let tab = TabBar.init(frame: CGRect.init(x: 0, y: 0, width: globalVariables.width, height: 64))
        tab.delegate = self
        return tab
    }()

    let titleLabel: UILabel = {
        let title = UILabel.init(frame: CGRect.init(x: 30, y: 17, width: 200, height: 30))
        title.font = UIFont(name: "Avenir-Medium", size: 25)!
        title.textColor = UIColor.white
        title.text = ""
        return title
    }()
    
    class func updateNav() {
    }
    
    // MARK: Methods
    func customization()  {
        // Collection View Customization
        self.collectionView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0)
        self.view.addSubview(self.collectionView)
        
        // Navigation Controller Customization
        // house background color
        let defaults = UserDefaults.standard
        let navigationColor = defaults.potter_colorForKey(key: "navCol")

        self.navigationController?.view.backgroundColor = navigationColor
        self.navigationController?.navigationItem.hidesBackButton = true
        self.navigationItem.hidesBackButton = true
        
        // Navigation Bar color and shadow
        self.navigationController?.navigationBar.barTintColor = navigationColor
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        // Title Label
        self.navigationController?.navigationBar.addSubview(self.titleLabel)
        
        // Tab Bar
        self.view.addSubview(self.tabBar)
        
        // View Controllers init
        for title in self.items {
            let storyBoard = self.storyboard!
            let vc = storyBoard.instantiateViewController(withIdentifier: title)
            self.addChildViewController(vc)
            vc.view.frame = CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: (self.view.bounds.height - 44))
            vc.didMove(toParentViewController: self)
            self.views.append(vc.view)
        }
        self.viewsAreInitialized = true
    }
    
    // MARK: Delegates implementation
    func didSelectItem(atIndex: Int) {
        self.collectionView.scrollRectToVisible(CGRect.init(origin: CGPoint.init(x: (self.view.bounds.width * CGFloat(atIndex)), y: 0), size: self.view.bounds.size), animated: true)
        
        }
    override func viewDidLoad() {
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        super.viewDidLoad()
        customization()
        
        // add notification center to switch tab
        let notificationName = Notification.Name("switchTab")
                NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.switchTab(notification:)), name: notificationName, object: nil)
    }
    
    func switchTab(notification: Notification) {
        // extract index from notification info
        guard let userInfo = notification.userInfo else {
            return
        }
        if let index = userInfo["index"] as? Int {
            // move to selected index
            didSelectItem(atIndex: index)
        }
    }
    
    // MARK: CollectionView DataSources
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.views.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.contentView.addSubview(self.views[indexPath.row])
        return cell
    }
    
    // MARK: Collection View Delegates
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
               return CGSize.init(width: self.view.bounds.width, height: (self.view.bounds.height + 22))
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollIndex = Int(round(scrollView.contentOffset.x / self.view.bounds.width))
        self.titleLabel.text = self.items[scrollIndex]
        if self.viewsAreInitialized {
            self.tabBar.whiteView.frame.origin.x = (scrollView.contentOffset.x / 4)
            self.tabBar.highlightItem(atIndex: scrollIndex)
        }
    }
}

