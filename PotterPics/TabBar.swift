//
//  TabBar.swift
//  PotterPics
//
//  Created by Suraya Shivji on 11/27/16.
//  Copyright © 2016 Suraya Shivji. All rights reserved.
//

protocol TabBarDelegate {
    func didSelectItem(atIndex: Int)
}

import UIKit
class TabBar: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: Properties
    let identifier = "cell"
    var darkItems = ["feedDark", "searchDark", "postDark", "profileDark"]
    let items = ["feed", "search", "post", "profile"]
    lazy var whiteView: UIView = {
        let wv = UIView.init(frame: CGRect.init(x: 0, y: self.frame.height - 5, width: self.frame.width / 4, height: 5))
        wv.backgroundColor = UIColor.potter_rbg(r: 245, g: 245, b: 245)
        return wv
    }()
    lazy var collectionView: UICollectionView  = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView.init(frame: CGRect.init(x: 0, y: 20, width: self.frame.width, height: (self.frame.height - 20)), collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = UIColor.clear
        cv.isScrollEnabled = false
        return cv
    }()
    var delegate: TabBarDelegate?
    
    //MARK: CollectionView DataSources
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! TabBarCellCollectionViewCell
        cell.icon.image = UIImage.init(named: darkItems[indexPath.row])
        
        if indexPath.row == 0 {
            cell.icon.image = UIImage.init(named: items[0])
            }
        return cell
    }
    
    //MARK: CollectionView Delegates
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: self.frame.width / 4, height: (self.frame.height - 20))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectItem(atIndex: indexPath.row)
    }
    
    // MARK: Methods
    func highlightItem(atIndex: Int)  {
        for index in  0...3 {
            let cell = collectionView.cellForItem(at: IndexPath.init(row: index, section: 0)) as! TabBarCellCollectionViewCell
            cell.icon.contentMode = UIViewContentMode.scaleAspectFit
            cell.icon.image = UIImage.init(named: darkItems[index])
        }
        let cell = collectionView.cellForItem(at: IndexPath.init(row: atIndex, section: 0)) as! TabBarCellCollectionViewCell
        cell.icon.contentMode = UIViewContentMode.scaleAspectFit
        cell.icon.image = UIImage.init(named: items[atIndex])
    }
    
    //MARK: - Inits
    override init(frame: CGRect) {
        super.init(frame: frame)
        collectionView.register(TabBarCellCollectionViewCell.self, forCellWithReuseIdentifier: identifier)
        let defaults = UserDefaults.standard
        let houseValue = defaults.string(forKey: "userHouse")
        // figure out items and dark items based on house
        switch houseValue! {
        case "Gryffindor":
            darkItems = ["GfeedDark", "GsearchDark", "GpostDark", "GprofileDark"]
            break
        case "Slytherin":
            darkItems = ["SfeedDark", "SsearchDark", "SpostDark", "SprofileDark"]
            break
        case "Hufflepuff":
            darkItems = ["HfeedDark", "HsearchDark", "HpostDark", "HprofileDark"]
            break
        case "Ravenclaw":
            darkItems = ["RfeedDark", "RsearchDark", "RpostDark", "RprofileDark"]
            break
        default:
            break
        }
        
        // house background color
        let navigationColor = defaults.potter_colorForKey(key: "navCol")
        self.backgroundColor = navigationColor
        
        addSubview(self.collectionView)
        addSubview(self.whiteView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// TabBarCell Class
class TabBarCellCollectionViewCell: UICollectionViewCell {
    
    let icon = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        let width = (self.contentView.bounds.width - 30) / 2
        icon.contentMode = UIViewContentMode.scaleAspectFit
        icon.frame = CGRect.init(x: width, y: 2, width: 30, height: 30)
        let image = UIImage.init(named: "home")
        icon.image = image?.withRenderingMode(.alwaysTemplate)
        self.contentView.addSubview(icon)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
