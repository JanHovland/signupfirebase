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

/*
 
 For å få Switch password til å komme i riktig posisjon, må du ikke bruke Stack View!
 Bruk kun constraints på avstandene mellom elementene!
 
 Det samme gjelder alle applikasjoner med text field og tastatur
 
 Kjente feil som må rettes
 
 1.
    Løsning:
 
 */

class LogInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var activity: UIActivityIndicatorView!
    @IBOutlet var eMailLoginTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet weak var loginStatus: UITextField!
    
    var status: Bool = true
    var activeField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setter "SHOWPASSWORD" til false
        UserDefaults.standard.set(false, forKey: "SHOWPASSWORD")
        
        // Setter "LOGGEDIN" til false
        UserDefaults.standard.set(false, forKey: "LOGGEDIN")

        // Observe keyboard change
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeLogin(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeLogin(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeLogin(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
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
        
        // For å kunne avslutte visning av tastatur når en trykker "Ferdig" på tastaturet
        eMailLoginTextField.delegate = self
        passwordTextField.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if (UserDefaults.standard.bool(forKey: "LOGGEDIN")) == true {
            loginStatus.text = showUserInfo(startUp: false)
        } else {
            loginStatus.text = showUserInfo(startUp: true)
        }
        
    }
    
    @objc func keyboardWillChangeLogin(notification: NSNotification) {
        
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }

        print(view.frame.size.height)
        print((activeField?.frame.size.height)!)
        
        print((activeField?.frame.origin.y)!)
        
        let distanceToBottom = view.frame.size.height - (activeField?.frame.origin.y)! - (activeField?.frame.size.height)!

        print("distanceToBottom = \(distanceToBottom)")
        print("keyboardRect = \(keyboardRect.height)")

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
        print("LogInView1")
       activeField = textField
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("LogInView2")
        activeField?.resignFirstResponder()
        activeField = nil
        return true
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
    
    override func viewWillDisappear(_ animated: Bool) {
        // Remove observers
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

}
