//
//  UpdateMailViewController.swift
//  signupfirebase
//
//  Created by Jan  on 21/11/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import Firebase
import UIKit

class UpdateMailViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var activity: UIActivityIndicatorView!
    @IBOutlet var oldEmailLabel: UILabel!
    @IBOutlet var newEmailTextField: UITextField!

    var myTimer: Timer!

    // Setter en "constant" forsinkelse etter at en trykker på "Save"
    let forsinkelse = 3

    override func viewDidLoad() {
        super.viewDidLoad()

        newEmailTextField.delegate = self

        activity.hidesWhenStopped = true
        activity.style = .gray
        view.addSubview(activity)

        activity.startAnimating()

        oldEmailLabel.text = Auth.auth().currentUser?.email

        activity.stopAnimating()
    }

    @IBAction func SaveNewEmail(_ sender: Any) {
        if (newEmailTextField.text?.count)! > 0 {
            activity.startAnimating()

            // Sender eposten på norsk:
            Auth.auth().languageCode = "no"

            // Legger inn ny opost i Firebase
            Auth.auth().currentUser?.updateEmail(to: newEmailTextField.text!)
            print("Oppdatert epost")

            // Legger inn den nye eposten i CoreData

            let ok = updateEpostCoreData(withOldEpost: oldEmailLabel.text!, withNewEpost: newEmailTextField.text!)

            if ok == false {
                presentAlert(withTitle: "Feil", message: "Kan ikke oppdatere eposten til brukeren i CoreData.")
            }

            activity.stopAnimating()

            // Legg inn en liten forsinkelse før funksjonen "returnToLogin" kalles
            myTimer = Timer.scheduledTimer(timeInterval: TimeInterval(forsinkelse), target: self, selector: #selector(returnToLogin), userInfo: nil, repeats: false)

        } else {
            // Legge ut varsel
            let melding = "Den nye eposten kan ikke være tom."
            presentAlert(withTitle: "ePost", message: melding)
        }
    }

    @objc func returnToLogin() {
        performSegue(withIdentifier: "BackToLoginViewController", sender: self)
        myTimer.invalidate()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        newEmailTextField.resignFirstResponder()
        return true
    }
}
