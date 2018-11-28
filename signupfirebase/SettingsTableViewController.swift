//
//  UpdateTableViewController.swift
//  signupfirebase
//
//  Created by Jan  on 05/11/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import Firebase
import UIKit

class SettingsTableViewController: UITableViewController {
    @IBOutlet var activity: UIActivityIndicatorView!

    @IBOutlet var settingsEmail: UILabel!
    @IBOutlet var settingsUserName: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        activity.hidesWhenStopped = true
        activity.style = .gray
        view.addSubview(activity)

        activity.startAnimating()

        // Henter brukernavn og passord fra FireBase

//        Auth.auth().signIn(withEmail: ePost, password: passOrd) { (user, error) in
//
//            if error == nil {
//
//                // Finner det gamle navnet
//
//                let user = Auth.auth().currentUser
//
//                if let user = user {
//                    self.settingsUserName.text = user.displayName
//                    self.settingsEmail.text = user.email
//                } else {
//                    // Håndtere error
//                }
//            }
//
//        }
//
        activity.stopAnimating()
    }

    override func viewDidAppear(_ animated: Bool) {
        activity.startAnimating()

        // Finner det gamle navnet

//        Auth.auth().signIn(withEmail: ePost, password: passOrd) { (user, error) in
//
//            if error == nil {
//
//                let user = Auth.auth().currentUser
//
//                if let user = user {
//                    self.settingsUserName.text = user.displayName
//                    self.settingsEmail.text = user.email
//                } else {
//                    // Håndtere error
//                }
//            } else {
//                // Håndtere error
//            }
//
//        }
//
        activity.stopAnimating()
    }
}
