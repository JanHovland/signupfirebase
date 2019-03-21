//
//  SettingsTableViewController.swift
//  signupfirebase
//
//  Created by Jan  on 05/11/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import Firebase
import UIKit

class SettingsTableViewController: UITableViewController {
    @IBOutlet var activity: UIActivityIndicatorView!

    @IBOutlet weak var userInfo: UILabel!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switchPassWord.isOn = false
        UserDefaults.standard.set(false, forKey: "SHOWPASSWORD")

        activity.hidesWhenStopped = true
        activity.style = .gray
        view.addSubview(activity)

    }
 
    override open var shouldAutorotate: Bool {
        return false
    }

    override func viewDidAppear(_ animated: Bool) {
        activity.startAnimating()
        activity.stopAnimating()
    }
    
    @IBOutlet var switchPassWord: UISwitch!
        
    @IBAction func changeSwitchPassword(_ sender: UISwitch) {
        
        if switchPassWord.isOn == false {
            switchPassWord.isOn = true
            UserDefaults.standard.set(true, forKey: "SHOWPASSWORD")
        } else {
            switchPassWord.isOn = false
            UserDefaults.standard.set(false, forKey: "SHOWPASSWORD")
        }
        
    }
    
}
