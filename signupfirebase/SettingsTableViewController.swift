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
        settingsEmail.text = Auth.auth().currentUser?.email
        settingsUserName.text = Auth.auth().currentUser?.displayName

        activity.stopAnimating()
    }
}
