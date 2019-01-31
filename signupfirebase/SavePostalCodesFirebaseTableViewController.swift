//
//  SavePostalCodesFirebaseTableViewController.swift
//  signupfirebase
//
//  Created by Jan  on 31/01/2019.
//  Copyright © 2019 Jan . All rights reserved.
//

import UIKit

class SavePostalCodesFirebaseTableViewController: UITableViewController {

    @IBOutlet weak var switchStorePostalCodes: UISwitch!
    
    @IBOutlet weak var userInfo: UILabel!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activity.hidesWhenStopped = true
        activity.style = .gray
        view.addSubview(activity)
        
        // Set the 'switchStorePostalCodes' to inaktive
        UserDefaults.standard.set(false, forKey: "SHOWSTOREPOSTALCODES")
        switchStorePostalCodes.isOn = false
        
    }

    override func viewDidAppear(_ animated: Bool) {
        userInfo.text = showUserInfo(startUp: false)
    }
    
    @IBAction func showStorePostalCodes(_ sender: Any) {
        if (UserDefaults.standard.bool(forKey: "SHOWSTOREPOSTALCODES")) == true {
            UserDefaults.standard.set(false, forKey: "SHOWSTOREPOSTALCODES")
            switchStorePostalCodes.isOn = false
        } else {
            UserDefaults.standard.set(true, forKey: "SHOWSTOREPOSTALCODES")
            switchStorePostalCodes.isOn = true
        }
    }
    
    @IBAction func StorePostalCodes(_ sender: UIBarButtonItem) {
        activity.startAnimating()
        print("StorePostalCodes")
        
        if (UserDefaults.standard.bool(forKey: "SHOWSTOREPOSTALCODES")) == true {
        
            UserDefaults.standard.set(true, forKey: "SHOWSTOREPOSTALCODES")
            switchStorePostalCodes.isOn = false
            
            savePostalCodesFiredata(postnummer: "0001",
                                    poststed: "Oslo")

            savePostalCodesFiredata(postnummer: "2340",
                                    poststed: "Løten")
           
            savePostalCodesFiredata(postnummer: "4360",
                                    poststed: "Varhaug")
            
        } else {
            let melding = NSLocalizedString("In order to save Postal Codes, the 'Store postal Codes' button must be enabled.",
                                            comment: "SavePostalCodesFirebaseTableViewController.swift StorePostalCodes")
            let melding1 = "\n" + melding
            self.presentAlert(withTitle: NSLocalizedString("Cannot store the postal codes.",
                                                           comment: "SavePostalCodesFirebaseTableViewController.swift StorePostalCodes"),
                              message: melding1)
        }
        
        activity.stopAnimating()

    }
    
}
