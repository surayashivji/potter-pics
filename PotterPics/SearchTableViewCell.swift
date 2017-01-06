//
//  SearchTableViewCell.swift
//  PotterPics
//
//  Created by Suraya Shivji on 12/5/16.
//  Copyright © 2016 Suraya Shivji. All rights reserved.
//

import UIKit


class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var searchImageView: UIImageView!
    @IBOutlet weak var searchName: UILabel!
    @IBOutlet weak var numPostsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
