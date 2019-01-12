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

    @IBOutlet var userInfo: UILabel!

    var myTimer: Timer!
    var teller: Int = 0
    var status: Bool = true

    var melding = ""
    var melding1 = ""
    var melding2 = ""
    var melding3 = ""

    let forsinkelse = 1
    var seconds = 3

    @IBOutlet var secondsLeft: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        secondsLeft.isHidden = true

        let melding1 = NSLocalizedString("After you have asked Firebase to reset your password, you will receive an eMail with istruction.",
                                         comment: "ResetPWByMailViewController.swift viewDidLoad ")

        let melding2 = NSLocalizedString("Please note that the included link is time limited!",
                                         comment: "ResetPWByMailViewController.swift viewDidLoad ")

        infoTextView.text = melding1 + "\n\n" + melding2

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
                
                self.melding1 = NSLocalizedString("Return to login in ", comment: "UpdatePasswordViewVontroller.swift SaveNewPassword ")
                self.melding2 = NSLocalizedString(" seconds", comment: "UpdatePasswordViewVontroller.swift SaveNewPassword ")
                self.melding3 = NSLocalizedString(" second", comment: "ResetPWByMailViewController.swift SaveNewPassword ")
                
                self.melding = self.melding1 + String(self.seconds) + self.melding2
                self.secondsLeft.isHidden = false
                self.secondsLeft.text = self.melding
                self.seconds -= 1

                self.myTimer = Timer.scheduledTimer(timeInterval: TimeInterval(self.forsinkelse),
                                                    target: self,
                                                    selector: #selector(self.returnToLogin),
                                                    userInfo: nil, repeats: true)

            } else {
                self.presentAlert(withTitle: NSLocalizedString("Error", comment: "ResetPWByMailViewController.swift resetByMail "),
                                  message: error?.localizedDescription as Any)
            }
        }

        activity.stopAnimating()
    }

    @objc func returnToLogin() {
        if seconds == 0 {
            secondsLeft.isHidden = true
            myTimer.invalidate()
            performSegue(withIdentifier: "BackToLoginViewController", sender: self)
        } else {
            if seconds == 2 {
                secondsLeft.text = melding1 + String(self.seconds) + melding2       // seconds
            } else {
                secondsLeft.text = melding1 + String(self.seconds) + melding3       // second
            }
            seconds -= 1
        }
    }

    @objc func showUserInformation() {
        userInfo.text = showUserInfo(startUp: false)
    }
}
