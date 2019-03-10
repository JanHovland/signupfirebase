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

class CreateAccountViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var activity: UIActivityIndicatorView!

    @IBOutlet var nameCreateAccountTextField: UITextField!
    @IBOutlet var eMailCreateAccountTextField: UITextField!
    @IBOutlet var passwordCreateAccountTextField: UITextField!
    
    var activeField: UITextField!

    // These 2 variables get their values via segue "gotoCreateAccount" in LogInViewController.swift
    var createEmail: String = ""
    var createPassord: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Turn off keyboard when you press "Return"
        self.nameCreateAccountTextField.delegate = self
        self.eMailCreateAccountTextField.delegate = self
        self.passwordCreateAccountTextField.delegate = self
        
        // Insert the values from LogInViewController.swift
        eMailCreateAccountTextField.text = createEmail
        passwordCreateAccountTextField.text = createPassord

        // Initialize the activity
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
            
            let region = NSLocale.current.regionCode?.lowercased()  // Returns the local region
            Auth.auth().languageCode = region!

            // Register the user with Firebase
            Auth.auth().createUser(withEmail: eMailCreateAccountTextField.text!,
                                   password: passwordCreateAccountTextField.text!) { _, error in

                if error == nil {
                    // The user is stored in Firebase

                    uid = Auth.auth().currentUser?.uid ?? ""
                    navn = self.nameCreateAccountTextField.text!

                    // Reset all posts where 'loggedin' == true
                    ok = self.resetLoggedIinCoreData()

                    if ok == true {
                        // Check if the user exists in CoreData
                        // Else, store the user in CoreData
                        ok = self.findCoreData(withEpost: self.eMailCreateAccountTextField.text!)

                        if ok == false {
                            
                            //  0 = uid  1 = ePost  2 = name  3 = passWord 4 = photoURL
                            let value1 = self.getCoreData()
                            
                            ok1 = self.saveCoreData(withEpost: self.eMailCreateAccountTextField.text!,
                                                    withPassord: self.passwordCreateAccountTextField.text!,
                                                    withUid: uid,
                                                    withLoggedIn: true,
                                                    withName: navn,
                                                    withPhotoURL: value1.photoURL)

                            if ok1 == false {
                                let melding = NSLocalizedString("Unable to store data in CoreData.",
                                                                comment: "CreateAccountViewVontroller.swift CheckLogin verdi")
                                
                                self.presentAlert(withTitle: NSLocalizedString("Error",
                                                                               comment: "CreateAccountViewVontroller.swift SaveAccount "),
                                                  message: melding)
                                
                            } else {
                                let region = NSLocale.current.regionCode?.lowercased()  // Returns the local region
                                Auth.auth().languageCode = region!
                                
                                let value2 = self.getCoreData()
                                
                                // Store the name of the user in Firebase
                                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                                changeRequest?.displayName = self.nameCreateAccountTextField.text!
                                changeRequest?.photoURL = URL(string: value2.photoURL)
                                
                                changeRequest?.commitChanges { error in
                                    if error == nil {
                                        self.dismiss(animated: false, completion: nil)
                                    } else {
                                        let melding = error!.localizedDescription
                                        self.presentAlert(withTitle: NSLocalizedString("Error", comment: "CreateAccountViewVontroller.swift SaveAccount"),
                                                          message: melding)
                                    }
                                }
                            }

                        } else {
                            // Update CoreData with 'loggedin' == true
                            ok = self.updateCoreData(withEpost: self.eMailCreateAccountTextField.text!, withLoggedIn: true)

                            if ok == false {
                                let melding = NSLocalizedString("Unable to store data in CoreData.",
                                                                comment: "CreateAccountViewVontroller.swift CheckLogin verdi")
                                
                                self.presentAlert(withTitle: NSLocalizedString("Error",
                                                                               comment: "CreateAccountViewVontroller.swift SaveAccount "),
                                                  message: melding)
                                
                            } else {
                                let region = NSLocale.current.regionCode?.lowercased()  // Returns the local region
                                Auth.auth().languageCode = region!

                                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                                changeRequest?.displayName = self.nameCreateAccountTextField.text!

                                changeRequest?.commitChanges { error in
                                    if error == nil {
                                        self.dismiss(animated: false, completion: nil)
                                    } else {
                                        let melding = error!.localizedDescription
                                        self.presentAlert(withTitle: NSLocalizedString("Error", comment: "CreateAccountViewVontroller.swift SaveAccount"),
                                                     message: melding)
                                    }
                                }
                            }
                        }

                    } else {
                        let melding = NSLocalizedString("Unable to store data in CoreData.",
                                                        comment: "CreateAccountViewVontroller.swift CheckLogin verdi")
                        
                        self.presentAlert(withTitle: NSLocalizedString("Error",
                                                                       comment: "CreateAccountViewVontroller.swift SaveAccount "),
                                          message: melding)
                        
                    }

                } else {
                    self.presentAlert(withTitle: NSLocalizedString("Error", comment: "CreateAccountViewVontroller.swift SaveAccount"),
                                      message: error!.localizedDescription as String)
                }
            }

        } else {
            if passwordCreateAccountTextField.text!.count < 6 {
                let melding1 = NSLocalizedString("Every field must have a value.", comment: "CreateAccountViewVontroller.swift SaveAccount ")
                let melding2 = NSLocalizedString("The password must contain minimum 6 characters", comment: "CreateAccountViewVontroller.swift SaveAccount ")
                let melding = melding1 + "\r\n" + melding2
                
                presentAlert(withTitle: NSLocalizedString("Error", comment: "CreateAccountViewVontroller.swift SaveAccount"),
                             message: melding)
            } else {
                let melding = NSLocalizedString("Every field must have a value", comment: "LoginViewVontroller.swift SaveAccount")
                presentAlert(withTitle: NSLocalizedString("Error", comment: "CreateAccountViewVontroller.swift SaveAccount"),
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
