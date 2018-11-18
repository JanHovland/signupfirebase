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

        // Henter epost pg passord fra Firebase
        getData()
        settingsEmail.text = ePost
        
        // Henter brukernavn fra FireBase
        
        Auth.auth().signIn(withEmail: ePost, password: passOrd) { (user, error) in
            
            // Check that error isn't nil
            
            if error == nil {
                
                let user = Auth.auth().currentUser
                
                if let user = user {
                    
                    self.settingsUserName.text = user.displayName
                    
                }
            }
        }
    }
    
}
