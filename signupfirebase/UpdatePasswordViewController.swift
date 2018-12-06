//
//  UpdatePasswordViewController.swift
//  signupfirebase
//
//  Created by Jan  on 18/11/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import Firebase
import UIKit

class UpdatePasswordViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var activity: UIActivityIndicatorView!
    @IBOutlet var oldPasswordTextField: UITextField!
    @IBOutlet var newPasswordTextField: UITextField!

    var myTimer: Timer!

    // Setter en "constant" forsinkelse etter at en trykker på "Save"
    let forsinkelse = 3

    override func viewDidLoad() {
        super.viewDidLoad()

        activity.hidesWhenStopped = true
        activity.style = .gray
        view.addSubview(activity)

        newPasswordTextField.delegate = self

        activity.startAnimating()

        // Finner aktuell epost fra Firebase
        let email = Auth.auth().currentUser?.email!

        // Finner passordet fra CoreData
        oldPasswordTextField.text! = findPasswordCoreData(withEpost: email!)

        if (UserDefaults.standard.bool(forKey: "SHOWPASSWORD")) == true {
            oldPasswordTextField.isSecureTextEntry = false
        } else {
            oldPasswordTextField.isSecureTextEntry = true
        }

        activity.stopAnimating()
    }

    @IBAction func SaveNewPassword(_ sender: Any) {
        activity.startAnimating()

        // Sender eposten på norsk:
        Auth.auth().languageCode = "no"

        // Oppdaterer passordet i Firebase
        Auth.auth().currentUser?.updatePassword(to: newPasswordTextField.text!) { error in

            if error != nil {
                self.presentAlertOption(withTitle: "Error", message: error!.localizedDescription as Any)
            } else {
                // Sender eposten på norsk:
                Auth.auth().languageCode = "no"

                // Lagrer passord i Coredata
                let ok = self.updatePasswordCoreData(withEpost: (Auth.auth().currentUser?.email!)!,
                                                     withPassWord: self.newPasswordTextField.text!)

                if ok == false {
                    self.presentAlert(withTitle: "Feil", message: "Kan ikke oppdatere passordet til brukeren i CoreData.")
                }

                // Legg inn en liten forsinkelse før funksjonen "returnToLogin" kalles
                self.myTimer = Timer.scheduledTimer(timeInterval: TimeInterval(self.forsinkelse),
                                                    target: self,
                                                    selector: #selector(self.returnToLogin),
                                                    userInfo: nil, repeats: false)
            }
        }

        activity.stopAnimating()
    }

    @objc func returnToLogin() {
        performSegue(withIdentifier: "BackToLoginViewController", sender: self)
        myTimer.invalidate()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        newPasswordTextField.resignFirstResponder()
        return true
    }
}
