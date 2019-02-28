//
//  PersonDataTableViewCell.swift
//  signupfirebase
//
//  Created by Jan  on 28/12/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import UIKit

class PersonDataTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bornLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var imageLabel: UIImageView! {
        didSet {
           imageLabel.layer.cornerRadius = imageLabel.bounds.width / 2
           imageLabel.clipsToBounds = true
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
