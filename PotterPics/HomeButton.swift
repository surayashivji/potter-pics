//
//  HomeButton.swift
//  PotterPicsSwift
//
//  Created by Suraya Shivji on 10/24/16.
//  Copyright © 2016 Suraya Shivji. All rights reserved.
//

import UIKit

class HomeButton: UIButton {
    override func awakeFromNib() {
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1.0
        layer.backgroundColor = UIColor.black.withAlphaComponent(0.55).cgColor
    }
    
}
