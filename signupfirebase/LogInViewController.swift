//
//  LogInViewController.swift
//  signupfirebase
//
//  Created by Jan  on 11/11/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import CoreData
import Firebase
import UIKit

class LogInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var activity: UIActivityIndicatorView!
    @IBOutlet var eMailLoginTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet weak var loginStatus: UITextField!
    
    var status: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setter "SHOWPASSWORD" til false
        UserDefaults.standard.set(false, forKey: "SHOWPASSWORD")
        
        // Setter "LOGGEDIN" til false
        UserDefaults.standard.set(false, forKey: "LOGGEDIN")

        // Brukes ikke lenger, men beholdes for å vise bruk av keyboard events
        // Listen for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name(rawValue: UIResponder.description()), object: nil)

        // For å kunne avslutte visning av tastatur når en trykker "Ferdig" på tastauuret
        eMailLoginTextField.delegate = self
        passwordTextField.delegate = self
        
        // Initierer UIActivityIndicatorView
        activity.hidesWhenStopped = true
        activity.style = .gray
        view.addSubview(activity)

        // Start activity
        activity.startAnimating()

        // Henter sist brukte eMail og Password der CoreData sin "loggedIn" = true
        // Hvis det ikke finnes noen post med loggedin = true, blankes eMailLoginTextField og passwordTextField
        let value = getCoreData()
        eMailLoginTextField.text = value.0
        passwordTextField.text = value.1

        activity.stopAnimating()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if (UserDefaults.standard.bool(forKey: "LOGGEDIN")) == true {
            loginStatus.text = showUserInfo(startUp: false)
        } else {
            loginStatus.text = showUserInfo(startUp: true)
        }
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        
        // Ikke i bruk lenger.
        
        if passwordTextField.isFirstResponder == true,
            passwordTextField.text!.count > 0,
            eMailLoginTextField.text!.count > 0 {
            // CheckLogin()
        }
        
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Dismiss the keyboard when the view is tapped on
        eMailLoginTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }

    @IBAction func LogIn(_ sender: UIBarButtonItem) {
        CheckLogin()
    }
    
    func CheckLogin() {
        
        var ok: Bool = false
        var ok1: Bool = false
        var uid: String = ""
        var navn: String = ""

        // Dismiss the keyboard when the Next button is tapped on
        eMailLoginTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()

        if eMailLoginTextField.text!.count > 0,
            passwordTextField.text!.count >= 6 {
            activity.startAnimating()

            // Sender eposten på norsk:
            Auth.auth().languageCode = "no"

            // Sjekk om eposten og passordet er registrert som bruker i Firebase
            Auth.auth().signIn(withEmail: eMailLoginTextField.text!, password: passwordTextField.text!) { _, error in

                if error == nil {
                    uid = Auth.auth().currentUser?.uid ?? ""
                    print("uid fra NextButtonTapped: \(uid)")

                    navn = Auth.auth().currentUser?.displayName ?? ""

                    // Resetter alle postene som hvor loggedin == true
                    ok = self.resetLoggedIinCoreData()

                    if ok == true {
                        // Sjekk om brukeren finnes i CoreData
                        // Hvis ikke, lagre brukeren i CoreData
                        ok = self.findCoreData(withEpost: self.eMailLoginTextField.text!)

                        if ok == false {
                            ok1 = self.saveCoreData(withEpost: self.eMailLoginTextField.text!,
                                                    withPassord: self.passwordTextField.text!,
                                                    withUid: uid,
                                                    withLoggedIn: true,
                                                    withName: navn)

                            if ok1 == false {
                                let melding = "Kan ikke lagre en ny post i CoreData."
                                self.presentAlert(withTitle: "Feil", message: melding)
                            }

                        } else {
                            // Finn passordet fra CoreData, dersom dette er forskjellig fra Firedata, oppdater CoreData
                            if self.findPasswordCoreData(withEpost: self.eMailLoginTextField.text!) != self.passwordTextField.text! {
                                // Legger det nye passordet inn i CoreData
                                ok = self.updatePasswordCoreData(withEpost: self.eMailLoginTextField.text!,
                                                                 withPassWord: self.passwordTextField.text!)

                                if ok == false {
                                    let melding = "Kan ikke oppdatere passordet i CoreData."
                                    self.presentAlert(withTitle: "Feil", message: melding)
                                }
                            }

                            // oppdaterer CoreData med loggedin == true
                            ok = self.updateCoreData(withEpost: self.eMailLoginTextField.text!, withLoggedIn: true)

                            if ok == false {
                                let melding = "Kan ikke oppdatere 'loggedin' i CoreData."
                                self.presentAlert(withTitle: "Feil", message: melding)
                            } else {
                                UserDefaults.standard.set(true, forKey: "LOGGEDIN")
                                
                                
                                
                                self.loginStatus.text = navn + " is logged in."
                            }
                        }

                    } else {
                        let melding = "Kan ikke oppdatere en post(er) i CoreData."
                        self.presentAlert(withTitle: "Feil", message: melding)
                    }

                } else {
                    self.presentAlertOption(withTitle: "Feil", message: error!.localizedDescription as Any)
                }
            }

            activity.stopAnimating()

        } else {
            let melding = "eMail må ha en verdi.\nPassword må være minst 6 tegn langt"
            presentAlert(withTitle: "Feil", message: melding)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        eMailLoginTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // prepare kjøres etter hvilken som helst segue.
        // Skal bare kjøres etter: performSegue(withIdentifier: "gotoCreateAccount", sender: self)

        if segue.identifier! == "gotoCreateAccount" {
            let vc = segue.destination as! CreateAccountViewController

            // createEmail og createPassord er variabler som er definert i CreateAccountViewController.swift
            vc.createEmail = eMailLoginTextField.text!
            vc.createPassord = passwordTextField.text!
        }
    }
}
