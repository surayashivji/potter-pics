//
//  PostFeedTableViewCell.swift
//  PotterPics
//
//  Created by Suraya Shivji on 12/7/16.
//  Copyright © 2016 Suraya Shivji. All rights reserved.
//

import UIKit

class PostFeedTableViewCell: UITableViewCell {

    @IBOutlet weak var captionIcon: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var smallProfileImg: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
