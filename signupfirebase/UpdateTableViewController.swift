//
//  UpdateTableViewController.swift
//  signupfirebase
//
//  Created by Jan  on 05/11/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    @IBOutlet weak var LogInEmail: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Henter fra den globale "ePost"
        LogInEmail.text = ePost
        
        // Henter brukernavn fra Firebase
        
        
        
        
    }
    
}
