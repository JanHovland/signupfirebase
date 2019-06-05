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
    @IBOutlet weak var forEmailTextField: UITextField!
    
    var activeField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Turn off keyboard when you press "Return"
        oldPasswordTextField.delegate = self
        newPasswordTextField.delegate = self
        forEmailTextField.delegate = self

        activity.hidesWhenStopped = true
        activity.style = .gray

        activity.startAnimating()

        DispatchQueue.main.async {
        
            // Find eMail from Firebase
            let email = Auth.auth().currentUser?.email!
            self.forEmailTextField.text = Auth.auth().currentUser?.email

           // Find password from CoreData
            self.oldPasswordTextField.text! = self.findPasswordCoreData(withEpost: email!)

            if (UserDefaults.standard.bool(forKey: "SHOWPASSWORD")) == true {
                self.oldPasswordTextField.isSecureTextEntry = false
                self.newPasswordTextField.isSecureTextEntry = false
            } else {
                self.oldPasswordTextField.isSecureTextEntry = true
                self.newPasswordTextField.isSecureTextEntry = true
            }
        }
        
        activity.stopAnimating()
    }

    override func viewDidAppear(_ animated: Bool) {
        // Observe keyboard change
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeUpdatePassword(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeUpdatePassword(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeUpdatePassword(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
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
        
        DispatchQueue.main.async {
        
            self.newPasswordTextField.resignFirstResponder()
        
            if self.newPasswordTextField.text!.count >= 6 {
                let region = NSLocale.current.regionCode
                Auth.auth().languageCode = region!.lowercased()

                Auth.auth().currentUser?.updatePassword(to: self.newPasswordTextField.text!) { error in

                    if error != nil {
                        self.presentAlert(withTitle: NSLocalizedString("Error", comment: "UpdatePasswordViewVontroller.swift SaveNewPassword "),
                                          message: error!.localizedDescription as Any)

                    } else {
                        let region = NSLocale.current.regionCode
                        Auth.auth().languageCode = region!.lowercased()

                        // Store the password in Coredata
                        let ok = self.updatePasswordCoreData(withEpost: (Auth.auth().currentUser?.email!)!,
                                                             withPassWord: self.newPasswordTextField.text!)

                        if ok == false {
                            let message = NSLocalizedString("Unable to update the password for the user in CoreData.", comment: "UpdatePasswordViewVontroller.swift SaveNewPassword ")

                            self.presentAlert(withTitle: NSLocalizedString("Error", comment: "UpdatePasswordViewVontroller.swift SaveNewPassword "),
                                              message: message)
                        }
                    }
                }
            } else {
                let message = NSLocalizedString("The password must contain minimum 6 characters", comment: "UpdatePasswordViewVontroller.swift SaveNewPassword")

                self.presentAlert(withTitle: NSLocalizedString("Error", comment: "UpdatePasswordViewVontroller.swift SaveNewPassword "),
                             message: message)
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
