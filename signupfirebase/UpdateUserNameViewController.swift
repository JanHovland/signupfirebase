//
//  UpdateUserNameViewController.swift
//  signupfirebase
//
//  Created by Jan  on 18/11/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import Firebase
import UIKit

class UpdateUserNameViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var activity: UIActivityIndicatorView!
    @IBOutlet var OldNameLabel: UILabel!
    @IBOutlet var NewNameTextField: UITextField!
    @IBOutlet weak var visUserInfo: UILabel!
    var myTimer: Timer!

    // Setter en "constant" forsinkelse etter at en trykker på "Save"
    let forsinkelse = 3

    override func viewDidLoad() {
        super.viewDidLoad()

        showUserInformation()
        
        NewNameTextField.delegate = self

        activity.hidesWhenStopped = true
        activity.style = .gray
        view.addSubview(activity)

        activity.startAnimating()

        OldNameLabel.text = Auth.auth().currentUser?.displayName

        activity.stopAnimating()
    }

    @IBAction func SaveNewName(_ sender: UIBarButtonItem) {
        if (NewNameTextField.text?.count)! > 0 {
            activity.startAnimating()

            // Sender eposten på norsk:
            Auth.auth().languageCode = "no"

            // Legger inn det nye navnet i Firebase
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = NewNameTextField.text
            changeRequest?.commitChanges { error in

                if error == nil {
                    self.OldNameLabel.text = self.NewNameTextField.text
                } else {
                    // Håndtere error
                    self.presentAlert(withTitle: "Error", message: error?.localizedDescription as Any)
                }
            }

            // Legger det nye navnet inn i CoreData
            let ok = updateNameCoreData(withEpost: (Auth.auth().currentUser?.email)!, withNavn: NewNameTextField.text!)

            if ok == false {
                presentAlert(withTitle: "Feil", message: "Kan ikke oppdatere navnet på brukeren i CoreData.")
            }

            activity.stopAnimating()

            // Legg inn en liten forsinkelse før funksjonen "returnToSettings" kalles
            myTimer = Timer.scheduledTimer(timeInterval: TimeInterval(forsinkelse), target: self, selector: #selector(showUserInformation), userInfo: nil, repeats: false)

        } else {
            // Legge ut varsel
            let melding = "Det nye navnet må ha en verdi."
            presentAlert(withTitle: "Tomt navn", message: melding)
        }
    }

    @objc func showUserInformation() {
        visUserInfo.text = showUserInfo(startUp: false)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        NewNameTextField.resignFirstResponder()
        return true
    }
}
