//
//  CoreDataTableViewCell.swift
//  signupfirebase
//
//  Created by Jan  on 02/12/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {
    @IBOutlet var uidLabel: UILabel!
    @IBOutlet var mailLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loggedInLabel: UILabel!
    @IBOutlet weak var photoURL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
