//
//  FilterCollectionViewCell.swift
//  PotterPicsSwift
//
//  Created by Suraya Shivji on 10/28/16.
//  Copyright © 2016 Suraya Shivji. All rights reserved.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var filteredImg: UIImageView! {
        didSet {
            filteredImg.contentMode = UIViewContentMode.scaleAspectFit
            filteredImg.image = UIImage(named: "filterPlaceholder")
        }
    }
    @IBOutlet weak var filteredLbl: UILabel!
}
