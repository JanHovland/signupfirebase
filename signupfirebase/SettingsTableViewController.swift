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

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var settingsEmail: UILabel!
    @IBOutlet weak var settingsUserName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .gray
        view.addSubview(activityIndicator)
        
        // Define layout constraint for the activityIndicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([activityIndicator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25.0),
                                     activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
        
        activityIndicator.startAnimating()
        
        // Henter brukernavn og passord fra FireBase
        
        Auth.auth().signIn(withEmail: ePost, password: passOrd) { (user, error) in
            
            // Check that error isn't nil
            
            if error == nil {
                
                let user = Auth.auth().currentUser
                
                if let user = user {
                    
                    self.settingsUserName.text = user.displayName
                    self.settingsEmail.text = user.email
                }
            }
        }
        
        activityIndicator.stopAnimating()
    }
    
}

