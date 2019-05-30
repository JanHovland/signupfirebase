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
    
    
    var X: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switchPassWord.isOn = false
        UserDefaults.standard.set(false, forKey: "SHOWPASSWORD")

    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override open var shouldAutorotate: Bool {
        return false
    }

    override func viewDidAppear(_ animated: Bool) {
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
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var heading = ""
        
        if section == 0 {
            let melding = NSLocalizedString("Users", comment: "SettingsTableViewController.swift SectionHeading")
            heading = melding
        } else if section == 1 {
            let melding = NSLocalizedString("Password", comment: "SettingsTableViewController.swift SectionHeading")
            heading = melding
        } else if section == 2 {
            let melding = NSLocalizedString("Other", comment: "SettingsTableViewController.swift SectionHeading")
            heading = melding
        } else if section == 3 {
            let melding = NSLocalizedString("Birthdays", comment: "SettingsTableViewController.swift SectionHeading")
            heading = melding
        }
        
        return heading
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // 'prepare' will run after every segue.
        if segue.identifier! == "gotoEmailFromSettings" {
        
            let vc = segue.destination as! EpostViewController
        
            vc.toRecipients = ""
            vc.subject = ""
            vc.messageBody = ""                      
            vc.mailInfo = "FromSettings"
            
        }
    }
}
