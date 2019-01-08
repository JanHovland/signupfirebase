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
    @IBOutlet var SendEmailToReceiver: UITextField!
    @IBOutlet var infoTextView: UITextView!

    @IBOutlet weak var userInfo: UILabel!
    
    var myTimer: Timer!
    var teller: Int = 0
    var status: Bool = true

    let forsinkelse = 3

    override func viewDidLoad() {
        super.viewDidLoad()
        
        infoTextView.text = NSLocalizedString("After you have asked Firebase to reset your password, you will receive an eMail with istruction. Please note that the included link is time limited!",
                                             comment: "ResetPWByMailViewController.swift viewDidLoad ")
        
        showUserInformation()

        infoTextView.isHidden = true

        activity.hidesWhenStopped = true
        activity.style = .gray
        view.addSubview(activity)

        activity.startAnimating()
        SendEmailToReceiver.text! = (Auth.auth().currentUser?.email)!
        activity.stopAnimating()

        if SendEmailToReceiver.text?.count == 0 {
           let melding = NSLocalizedString("Unable to recall the eMail from Firebase.", comment: "ResetPWByMailViewController.swift viewDidLoad ")
           presentAlert(withTitle: NSLocalizedString("Error", comment: "ResetPWByMailViewController.swift viewDidLoad "),
                        message: melding)
        }
    }

    @IBAction func info(_ sender: Any) {
        status = !status
        infoTextView.isHidden = status
    }

    @IBAction func resetByMail(_ sender: UIBarButtonItem) {
        activity.startAnimating()

        // Send the eMail on the local region
        
        let region = NSLocale.current.regionCode?.lowercased()
        Auth.auth().languageCode = region!
        
        Auth.auth().sendPasswordReset(withEmail: SendEmailToReceiver.text!) { error in
            if error == nil {
                // Set a short delay before the function "returnToLogin" is called
                self.myTimer = Timer.scheduledTimer(timeInterval: TimeInterval(self.forsinkelse),
                                                    target: self,
                                                    selector: #selector(self.returnToLogin),
                                                    userInfo: nil, repeats: false)

            } else {
                self.presentAlert(withTitle: NSLocalizedString("Error", comment: "ResetPWByMailViewController.swift velgeKjonn "),
                                  message: error?.localizedDescription as Any)
            }
        }

        activity.stopAnimating()
    }

    @objc func returnToLogin() {
        performSegue(withIdentifier: "BackToLoginViewController", sender: self)
        myTimer.invalidate()
    }
    
    @objc func showUserInformation() {
        userInfo.text = showUserInfo(startUp: false)
    }
    
    
}
