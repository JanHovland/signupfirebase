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

    var myTimer: Timer!
    var teller: Int = 0
    var status: Bool = true

    // Setter en "constant" forsinkelse etter at en trykker på "Save"
    let forsinkelse = 3

    override func viewDidLoad() {
        super.viewDidLoad()

        infoTextView.isHidden = true

        activity.hidesWhenStopped = true
        activity.style = .gray
        view.addSubview(activity)

        activity.startAnimating()
        SendEmailToReceiver.text! = (Auth.auth().currentUser?.email)!
        activity.stopAnimating()

        if SendEmailToReceiver.text?.count == 0 {
            let melding = "Kan ikke hente eposten fra Firebase."
            presentAlert(withTitle: "Feil", message: melding)
        }
    }

    @IBAction func info(_ sender: Any) {
        status = !status
        infoTextView.isHidden = status
    }

    @IBAction func resetByMail(_ sender: UIBarButtonItem) {
        activity.startAnimating()

        // Sender eposten på norsk:
        Auth.auth().languageCode = "no"
        Auth.auth().sendPasswordReset(withEmail: SendEmailToReceiver.text!) { error in
            if error == nil {
                // Legg inn en liten forsinkelse før funksjonen "returnToLogin" kalles
                self.myTimer = Timer.scheduledTimer(timeInterval: TimeInterval(self.forsinkelse),
                                                    target: self,
                                                    selector: #selector(self.returnToLogin),
                                                    userInfo: nil, repeats: false)

            } else {
                self.presentAlert(withTitle: "Error", message: error?.localizedDescription as Any)
            }
        }

        activity.stopAnimating()
    }

    @objc func returnToLogin() {
        performSegue(withIdentifier: "BackToLoginViewController", sender: self)
        myTimer.invalidate()
    }
}
