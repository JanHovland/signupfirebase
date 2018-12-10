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
        // settingsEmail.text = Auth.auth().currentUser?.email
        let value = getCoreData()
        settingsEmail.text = value.0
        settingsUserName.text = value.2
        
        print(value.0)
        print(value.1)
        print(value.2)
        
        activity.stopAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let value = getCoreData()
        settingsEmail.text = value.0
        settingsUserName.text = value.2
        
        print(value.0)
        print(value.1)
        print(value.2)
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
