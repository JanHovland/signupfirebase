//
//  CoreDataTableViewCell.swift
//  signupfirebase
//
//  Created by Jan  on 02/12/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import UIKit

class CoreDataTableViewCell: UITableViewCell {
    @IBOutlet var uidLabel: UILabel!
    @IBOutlet var mailLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
