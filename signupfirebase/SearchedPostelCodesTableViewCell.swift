//
//  SearchedPostelCodesTableViewCell.swift
//  signupfirebase
//
//  Created by Jan  on 12/02/2019.
//  Copyright © 2019 Jan . All rights reserved.
//

import UIKit

class SearchedPostelCodesTableViewCell: UITableViewCell {

    @IBOutlet weak var postalCodeLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var municipalityInfoLabel: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

}
