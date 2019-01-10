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
    @IBOutlet var userInfo: UILabel!

    var myTimer: Timer!
    var activeField: UITextField!

    var melding = ""
    var melding1 = ""
    var melding2 = ""
    
    let forsinkelse = 1
    var seconds = 3

    @IBOutlet var secondsLeft: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        secondsLeft.isHidden = true

        showUserInformation()

        // Turn off keyboard when you press "Return"
        newPasswordTextField.delegate = self

        activity.hidesWhenStopped = true
        activity.style = .gray
        view.addSubview(activity)

        activity.startAnimating()

        // Find eMail from Firebase
        let email = Auth.auth().currentUser?.email!

        // Find password from CoreData
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
        
        newPasswordTextField.resignFirstResponder()
        
        if newPasswordTextField.text!.count >= 6 {
            let region = NSLocale.current.regionCode
            Auth.auth().languageCode = region!.lowercased()

            Auth.auth().currentUser?.updatePassword(to: newPasswordTextField.text!) { error in

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
                        let melding = NSLocalizedString("Unable to update the password for the user in CoreData.", comment: "UpdatePasswordViewVontroller.swift SaveNewPassword ")

                        self.presentAlert(withTitle: NSLocalizedString("Error", comment: "UpdatePasswordViewVontroller.swift SaveNewPassword "),
                                          message: melding)
                    } else {

                        self.melding1 = NSLocalizedString("Return to login in: ", comment: "UpdatePasswordViewVontroller.swift SaveNewPassword ")
                        self.melding2 = NSLocalizedString(" seconds", comment: "UpdatePasswordViewVontroller.swift SaveNewPassword ")
                        
                        self.melding = self.melding1 + String(self.seconds) + self.melding2
                        self.secondsLeft.isHidden = false
                        self.secondsLeft.text = self.melding
                        
                        self.seconds -= 1

                        self.myTimer = Timer.scheduledTimer(timeInterval: TimeInterval(self.forsinkelse),
                                                            target: self,
                                                            selector: #selector(self.returnToLogin),
                                                            userInfo: nil, repeats: true)
                    }
                }
            }
        } else {
            let melding = NSLocalizedString("The password must contain minimum 6 characters", comment: "UpdatePasswordViewVontroller.swift SaveNewPassword")

            presentAlert(withTitle: NSLocalizedString("Error", comment: "UpdatePasswordViewVontroller.swift SaveNewPassword "),
                         message: melding)
        }

        activity.stopAnimating()
    }

    @objc func returnToLogin() {
        if seconds == 0 {
            secondsLeft.isHidden = true
            myTimer.invalidate()
            performSegue(withIdentifier: "BackToLoginViewController", sender: self)
        } else {
            secondsLeft.text = melding1 + String(self.seconds) + melding2
            seconds -= 1
        }
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
