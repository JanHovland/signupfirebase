//
//  UpdatePasswordViewController.swift
//  signupfirebase
//
//  Created by Jan  on 18/11/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

/*
 
 For å få Switch password til å komme i riktig posisjon, må du ikke bruke Stack View!
 Bruk kun constraints på avstandene mellom elementene!
 
 Det samme gjelder alle applikasjoner med text field og tastatur
 
 Kjente feil som må rettes
 
 1.
 Løsning:
 
 */

import Firebase
import UIKit

class UpdatePasswordViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var activity: UIActivityIndicatorView!
    @IBOutlet var oldPasswordTextField: UITextField!
    @IBOutlet var newPasswordTextField: UITextField!
    @IBOutlet var userInfo: UILabel!
    
    var myTimer: Timer!
    var activeField: UITextField!

    // Setter en "constant" forsinkelse etter at en trykker på "Save"
    let forsinkelse = 3

    override func viewDidLoad() {
        super.viewDidLoad()

        // Observe keyboard change
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeUpdatePassword(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeUpdatePassword(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeUpdatePassword(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        showUserInformation()

        // For å kunne avslutte visning av tastatur når en trykker "Ferdig" på tastaturet
        self.newPasswordTextField.delegate = self
        
        activity.hidesWhenStopped = true
        activity.style = .gray
        view.addSubview(activity)

        activity.startAnimating()

        // Finner aktuell epost fra Firebase
        let email = Auth.auth().currentUser?.email!

        // Finner passordet fra CoreData
        oldPasswordTextField.text! = findPasswordCoreData(withEpost: email!)

        if (UserDefaults.standard.bool(forKey: "SHOWPASSWORD")) == true {
            oldPasswordTextField.isSecureTextEntry = false
            newPasswordTextField.isSecureTextEntry = false
        } else {
            oldPasswordTextField.isSecureTextEntry = true
            newPasswordTextField.isSecureTextEntry = true
        }

        activity.stopAnimating()
    }

    override func viewDidAppear(_ animated: Bool) {
        
        activity.startAnimating()
        userInfo.text = showUserInfo(startUp: false)
        activity.stopAnimating()
    }

    @objc func keyboardWillChangeUpdatePassword(notification: NSNotification) {
        
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
        newPasswordTextField.resignFirstResponder()
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

            }
        }

        activity.stopAnimating()
    }

    @objc func showUserInformation() {
        userInfo.text = showUserInfo(startUp: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        // Remove observers
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
}
