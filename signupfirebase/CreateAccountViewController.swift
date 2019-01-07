//
//  CreateAccountViewController.swift
//  signupfirebase
//
//  Created by Jan  on 12/11/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import CoreData
import Firebase
import UIKit

/*
 
 For å få Switch password til å komme i riktig posisjon, må du ikke bruke Stack View!
 Bruk kun constraints på avstandene mellom elementene!
 
 Det samme gjelder alle applikasjoner med text field og tastatur
 
 Kjente feil som må rettes
 
 1.
 Løsning:
 
 */

class CreateAccountViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var activity: UIActivityIndicatorView!

    @IBOutlet var nameCreateAccountTextField: UITextField!
    @IBOutlet var eMailCreateAccountTextField: UITextField!
    @IBOutlet var passwordCreateAccountTextField: UITextField!
    
    var activeField: UITextField!

    // Disse 2 variable som får verdier via segue "gotoCreateAccount" i LogInViewController.swift
    var createEmail: String = ""
    var createPassord: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // For å kunne avslutte visning av tastatur når en trykker "Ferdig" på tastaturet
        self.nameCreateAccountTextField.delegate = self
        self.eMailCreateAccountTextField.delegate = self
        self.passwordCreateAccountTextField.delegate = self
        
        // Setter inn variablene fra LogInViewController.swift
        eMailCreateAccountTextField.text = createEmail
        passwordCreateAccountTextField.text = createPassord

        // Init av activity
        activity.hidesWhenStopped = true
        activity.style = .gray
        view.addSubview(activity)
        
    }

    override func viewDidAppear(_ animated: Bool) {
        // Observe keyboard change
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeCreateAccount(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeCreateAccount(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeCreateAccount(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    @objc func keyboardWillChangeCreateAccount(notification: NSNotification) {
        
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }

        let distanceToBottom = view.frame.size.height - (activeField?.frame.origin.y)! - (activeField?.frame.size.height)!

        if keyboardRect.height > distanceToBottom {

            if notification.name == UIResponder.keyboardWillShowNotification ||
                notification.name == UIResponder.keyboardWillChangeFrameNotification {
                view.frame.origin.y = -(keyboardRect.height - distanceToBottom)
            } else {
                view.frame.origin.y = 0
            }

        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        activeField?.resignFirstResponder()
        activeField = nil
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Dismiss the keyboard when the view is tapped on
        eMailCreateAccountTextField.resignFirstResponder()
        nameCreateAccountTextField.resignFirstResponder()
        passwordCreateAccountTextField.resignFirstResponder()
    }

    @IBAction func SaveAccount(_ sender: UIBarButtonItem) {
        var ok: Bool = false
        var ok1: Bool = false
        var uid: String = ""
        var navn: String = ""

        activity.startAnimating()

        // Dismiss the keyboard when the Save button is tapped on
        eMailCreateAccountTextField.resignFirstResponder()
        nameCreateAccountTextField.resignFirstResponder()
        passwordCreateAccountTextField.resignFirstResponder()

        if eMailCreateAccountTextField.text!.count > 0,
            nameCreateAccountTextField.text!.count > 0,
            passwordCreateAccountTextField.text!.count >= 6 {
            // Sender eposten på norsk:
            Auth.auth().languageCode = "no"

            // Register the user with Firebase
            Auth.auth().createUser(withEmail: eMailCreateAccountTextField.text!,
                                   password: passwordCreateAccountTextField.text!) { _, error in

                if error == nil {
                    // Brukeren er nå opprettet i Firebase

                    uid = Auth.auth().currentUser?.uid ?? ""
                    navn = self.nameCreateAccountTextField.text!

                    // Resetter alle postene som hvor loggedin == true
                    ok = self.resetLoggedIinCoreData()

                    if ok == true {
                        // Sjekk om brukeren finnes i CoreData
                        // Hvis ikke, lagre brukeren i CoreData
                        ok = self.findCoreData(withEpost: self.eMailCreateAccountTextField.text!)

                        if ok == false {
                            ok1 = self.saveCoreData(withEpost: self.eMailCreateAccountTextField.text!,
                                                    withPassord: self.passwordCreateAccountTextField.text!,
                                                    withUid: uid,
                                                    withLoggedIn: true,
                                                    withName: navn)

                            if ok1 == false {
                                let melding = NSLocalizedString("Unable to store data in CoreData.",
                                                                comment: "CreateAccountViewVontroller.swift CheckLogin verdi")
                                
                                self.presentAlert(withTitle: NSLocalizedString("Error",
                                                                               comment: "LoginViewVontroller.swift SaveAccount "),
                                                  message: melding)
                                
                            } else {
                                // Sender eposten på norsk:
                                Auth.auth().languageCode = "no"

                                // Legg inn Navnet på brukeren i Firebase
                                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                                changeRequest?.displayName = self.nameCreateAccountTextField.text!

                                changeRequest?.commitChanges { error in
                                    if error == nil {
                                        self.dismiss(animated: false, completion: nil)
                                    } else {
                                        print("Error: \(error!.localizedDescription)")
                                    }
                                }
                            }

                        } else {
                            // oppdaterer CoreData med loggedin == true
                            ok = self.updateCoreData(withEpost: self.eMailCreateAccountTextField.text!, withLoggedIn: true)

                            if ok == false {
                                let melding = NSLocalizedString("Unable to store data in CoreData.",
                                                                comment: "CreateAccountViewVontroller.swift CheckLogin verdi")
                                
                                self.presentAlert(withTitle: NSLocalizedString("Error",
                                                                               comment: "LoginViewVontroller.swift SaveAccount "),
                                                  message: melding)
                                
                            } else {
                                // Legg inn Navnet på brukeren

                                // Sender eposten på norsk:
                                Auth.auth().languageCode = "no"

                                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                                changeRequest?.displayName = self.nameCreateAccountTextField.text!

                                changeRequest?.commitChanges { error in
                                    if error == nil {
                                        self.dismiss(animated: false, completion: nil)
                                    } else {
                                        print("Error: \(error!.localizedDescription)")
                                    }
                                }
                            }
                        }

                        // Går til
                        // self.performSegue(withIdentifier: "UpdateUserDataFromCreateAccount", sender: self)

                    } else {
                        let melding = NSLocalizedString("Unable to store data in CoreData.",
                                                        comment: "CreateAccountViewVontroller.swift CheckLogin verdi")
                        
                        self.presentAlert(withTitle: NSLocalizedString("Error",
                                                                       comment: "LoginViewVontroller.swift SaveAccount "),
                                          message: melding)
                        
                    }

                } else {
                    self.presentAlert(withTitle: NSLocalizedString("Error", comment: "LoginViewVontroller.swift SaveAccount"),
                                      message: error!.localizedDescription as Any)
                }
            }

        } else {
            if passwordCreateAccountTextField.text!.count < 6 {
                let melding = NSLocalizedString("Every field must have a value. \r\nThe password must contain minimum 6 characters", comment: "LoginViewVontroller.swift SaveAccount ")
                presentAlert(withTitle: NSLocalizedString("Error", comment: "LoginViewVontroller.swift SaveAccount"),
                             message: melding)
            } else {
                let melding = NSLocalizedString("Every field must have a value", comment: "LoginViewVontroller.swift SaveAccount")
                presentAlert(withTitle: NSLocalizedString("Error", comment: "LoginViewVontroller.swift SaveAccount"),
                             message: melding)
            }
        }

        activity.stopAnimating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Remove observers
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
}
