//
//  BirthdayTableViewCell.swift
//  signupfirebase
//
//  Created by Jan Hovland on 27/04/2019.
//  Copyright © 2019 Jan . All rights reserved.
//

import UIKit

class BirthdayTableViewCell: UITableViewCell {
    
    var phoneNumber: String = ""
    var firstName: String = ""

    @IBOutlet weak var birthdayLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

