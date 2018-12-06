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

        // Setter switchPassWord til av
        if (UserDefaults.standard.bool(forKey: "SHOWPASSWORD")) == true {
            switchPassWord.isOn = true
        } else {
            switchPassWord.isOn = false
        }

        activity.hidesWhenStopped = true
        activity.style = .gray
        view.addSubview(activity)

        activity.startAnimating()

        // Henter brukernavn og passord fra FireBase
        settingsEmail.text = Auth.auth().currentUser?.email
        settingsUserName.text = Auth.auth().currentUser?.displayName

        activity.stopAnimating()
    }

    @IBAction func showPassword(_ sender: UISwitch) {
        if (UserDefaults.standard.bool(forKey: "SHOWPASSWORD")) == true {
            UserDefaults.standard.set(false, forKey: "SHOWPASSWORD")
            switchPassWord.isOn = false
        } else {
            UserDefaults.standard.set(true, forKey: "SHOWPASSWORD")
            switchPassWord.isOn = true
        }
    }

    @IBOutlet var switchPassWord: UISwitch!
}
