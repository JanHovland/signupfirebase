//
//  ResetPWByMailViewController.swift
//  signupfirebase
//
//  Created by Jan  on 04/12/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import Firebase
import UIKit

class ResetPWByMailViewController: UIViewController {
    
    @IBOutlet var activity: UIActivityIndicatorView!
    @IBOutlet var infoTextView: UITextView!
    @IBOutlet weak var sendEmailToReceiver: UITextField!
    @IBOutlet var userInfo: UILabel!

    var myTimer: Timer!
    var teller: Int = 0
    var status: Bool = true

    var message = ""
    var message1 = ""
    var message2 = ""
    var message3 = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let message1 = NSLocalizedString("After you have asked Firebase to reset your password, you will receive an eMail with istruction.",
                                         comment: "ResetPWByMailViewController.swift viewDidLoad ")

        let message2 = NSLocalizedString("Please note that the included link is time limited!",
                                         comment: "ResetPWByMailViewController.swift viewDidLoad ")

        infoTextView.text = message1 + "\n\n" + message2
        infoTextView.isHidden = true
        // Must update the colors and background (Early version ?)
        
        infoTextView.textColor = .label
        infoTextView.backgroundColor = .systemBackground
        
        sendEmailToReceiver.textColor = .label
        sendEmailToReceiver.backgroundColor = .systemBackground
        
        activity.hidesWhenStopped = true
        activity.style = UIActivityIndicatorView.Style.medium

        activity.startAnimating()
       
        DispatchQueue.main.async {
            self.sendEmailToReceiver.text! = (Auth.auth().currentUser?.email)!
        
            if self.sendEmailToReceiver.text?.count == 0 {
                let message = NSLocalizedString("Unable to recall the eMail from Firebase.", comment: "ResetPWByMailViewController.swift viewDidLoad ")
                self.presentAlert(withTitle: NSLocalizedString("Error", comment: "ResetPWByMailViewController.swift viewDidLoad "),
                             message: message)
            }
        }
        activity.stopAnimating()

    }

    @IBAction func info(_ sender: Any) {
        status = !status
        infoTextView.isHidden = status
    }

    @IBAction func sendResetRequest(_ sender: UIBarButtonItem) {
     
        activity.startAnimating()

        DispatchQueue.main.async {
            // Send the eMail for the local region
            let region = NSLocale.current.regionCode?.lowercased()
            Auth.auth().languageCode = region!

            Auth.auth().sendPasswordReset(withEmail: self.sendEmailToReceiver.text!) { error in
                if error != nil {
                    self.presentAlert(withTitle: NSLocalizedString("Error", comment: "ResetPWByMailViewController.swift resetByMail "),
                                      message: error?.localizedDescription as Any)
                } else {
                    
                    let title = NSLocalizedString("Password change request has been sent", comment: "ResetPWByMailViewController.swift resetByMail ")
                    let message1 = NSLocalizedString("Please look in your email", comment: "ResetPWByMailViewController.swift resetByMail ")
                    let message = "\n" + message1
    
                    self.presentAlert(withTitle: title,
                                      message: message)
                    
                }
            }

        }
        
        activity.stopAnimating()
    }

}
