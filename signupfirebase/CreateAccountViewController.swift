//
//  CreateAccountViewController.swift
//  signupfirebase
//
//  Created by Jan  on 12/11/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

// import FirebaseAuth
import CoreData
import Firebase
import UIKit

class CreateAccountViewController: UIViewController {
    @IBOutlet var activity: UIActivityIndicatorView!

    @IBOutlet var nameCreateAccountTextField: UITextField!
    @IBOutlet var eMailCreateAccountTextField: UITextField!
    @IBOutlet var passwordCreateAccountTextField: UITextField!

    // Disse 2 variable som får verdier via segue "gotoCreateAccount" i LogInViewController.swift
    var createEmail: String = ""
    var createPassord: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setter inn variablene fra LogInViewController.swift
        eMailCreateAccountTextField.text = createEmail
        passwordCreateAccountTextField.text = createPassord

        // Init av activity
        activity.hidesWhenStopped = true
        activity.style = .gray
        view.addSubview(activity)
    }

    override func viewWillAppear(_ animated: Bool) {
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

        activity.startAnimating()

        // Dismiss the keyboard when the Save button is tapped on
        eMailCreateAccountTextField.resignFirstResponder()
        nameCreateAccountTextField.resignFirstResponder()
        passwordCreateAccountTextField.resignFirstResponder()

        if eMailCreateAccountTextField.text!.count > 0,
            nameCreateAccountTextField.text!.count > 0,
            passwordCreateAccountTextField.text!.count >= 6 {
            // Register the user with Firebase
            Auth.auth().createUser(withEmail: eMailCreateAccountTextField.text!,
                                   password: passwordCreateAccountTextField.text!) { _, error in

                if error == nil {
                    // Brukeren er nå opprettet i Firebase

                    uid = Auth.auth().currentUser?.uid ?? ""
                    print("uid fra SaveAccount: \(uid)")

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
                                                    withLoggedIn: true)

                            if ok1 == false {
                                let melding = "Kan ikke lagre en ny post i CoreData."
                                self.presentAlert(withTitle: "Feil", message: melding)
                            } else {
                                // Legg inn Navnet på brukeren
                                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                                changeRequest?.displayName = self.nameCreateAccountTextField.text!

                                changeRequest?.commitChanges { error in
                                    if error == nil {
                                        print("Lagret navn på brukeren!")
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
                                let melding = "Kan ikke oppdatere en post i CoreData."
                                self.presentAlert(withTitle: "Feil", message: melding)
                            } else {
                                // Legg inn Navnet på brukeren
                                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                                changeRequest?.displayName = self.nameCreateAccountTextField.text!

                                changeRequest?.commitChanges { error in
                                    if error == nil {
                                        print("Lagret navn på brukeren!")
                                        self.dismiss(animated: false, completion: nil)
                                    } else {
                                        print("Error: \(error!.localizedDescription)")
                                    }
                                }
                            }
                        }

                        // Går til
                        self.performSegue(withIdentifier: "UpdateUserDataFromCreateAccount", sender: self)

                    } else {
                        let melding = "Kan ikke oppdatere en post(er) i CoreData."
                        self.presentAlert(withTitle: "Feil", message: melding)
                    }

                } else {
                    self.presentAlert(withTitle: "Error", message: error!.localizedDescription as Any)
                }
            }

        } else {
            if passwordCreateAccountTextField.text!.count < 6 {
                presentAlert(withTitle: "Feil", message: "Alle feltene må ha verdi. \nPassordet må ha minst 6 tegn")
            } else {
                presentAlert(withTitle: "Feil", message: "Alle feltene må ha verdi.")
            }
        }

        activity.stopAnimating()
    }
}
