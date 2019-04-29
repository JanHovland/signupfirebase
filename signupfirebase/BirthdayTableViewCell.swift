//
//  BirthdayTableViewCell.swift
//  signupfirebase
//
//  Created by Jan Hovland on 27/04/2019.
//  Copyright © 2019 Jan . All rights reserved.
//

import UIKit

class BirthdayTableViewCell: UITableViewCell {

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

    @IBAction func sendMessage(_ sender: Any) {
       print("Sending a message to Qwerty")
    }
}
