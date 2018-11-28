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

//        Auth.auth().signIn(withEmail: ePost, password: passOrd) { (user, error) in
//
//            if error == nil {
//
//                // Setter inn den gamle eposten
//
//                let user = Auth.auth().currentUser
//
//                if user != nil {
//                    self.oldEmailLabel.text = user!.email
//                }
//            } else {
//                // Håndtere error
//                self.presentAlert(withTitle: "Error", message: error?.localizedDescription as Any)
//            }
//
//            self.activity.stopAnimating()
//        }
//
    }

    @IBAction func SaveNewEmail(_ sender: Any) {
        if (newEmailTextField.text?.count)! > 0 {
            activity.startAnimating()

            // Legger inn ny opost
            Auth.auth().currentUser?.updateEmail(to: newEmailTextField.text!)
            print("Oppdatert epost")
//            ePost = self.newEmailTextField.text!

//            self.deleteAllData()

            // Lagrer epost og passord i Coredata
            // self.saveData()

            activity.stopAnimating()

            // Legg inn en liten forsinkelse før funksjonen "returnToLogin" kalles
            myTimer = Timer.scheduledTimer(timeInterval: TimeInterval(forsinkelse), target: self, selector: #selector(returnToLogin), userInfo: nil, repeats: false)

        } else {
            // Legge ut varsel
            let melding = "Den nye eposten kan ikke være tom."
            presentAlert(withTitle: "Tomt navn", message: melding)
        }
    }

    @objc func returnToLogin() {
        performSegue(withIdentifier: "BackToLoginViewController", sender: self)
        myTimer.invalidate()
//        print(ePost)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        newEmailTextField.resignFirstResponder()
        return true
    }
}
