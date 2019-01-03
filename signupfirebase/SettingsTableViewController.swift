//
//  SettingsTableViewController.swift
//  signupfirebase
//
//  Created by Jan  on 05/11/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

/*
    For å få Switch password til å komme i riktig posisjon, må du ikke bruke Stack View!
    Bruk kun constraints på avstandene mellom elementene!
 
 */

import Firebase
import UIKit

class SettingsTableViewController: UITableViewController {
    @IBOutlet var activity: UIActivityIndicatorView!

    @IBOutlet weak var userInfo: UILabel!
 
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setter switchPassWord til inaktive
        if (UserDefaults.standard.bool(forKey: "SHOWPASSWORD")) == true {
            switchPassWord.isOn = true
        } else {
            switchPassWord.isOn = false
        }

        activity.hidesWhenStopped = true
        activity.style = .gray
        view.addSubview(activity)

    }
    
    override open var shouldAutorotate: Bool {
        return false
    }

    override func viewDidAppear(_ animated: Bool) {
        activity.startAnimating()
        userInfo.text = showUserInfo(startUp: false)
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
