//
//  UpdateTableViewController.swift
//  signupfirebase
//
//  Created by Jan  on 05/11/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import UIKit
import Firebase

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var settingsEmail: UILabel!
    
    @IBOutlet weak var settingsUserName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Henter epost fra Firebase
        getData()
        settingsEmail.text = ePost
        
        // Henter brukernavn fra FireBase
        let user = Auth.auth().currentUser
        if let user = user {
            
            settingsUserName.text = user.displayName
            
        }
        
    }
    
}
