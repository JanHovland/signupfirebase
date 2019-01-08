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
    @IBOutlet var NewNameTextField: UITextField!
    @IBOutlet weak var userInfo: UILabel!
    @IBOutlet weak var OldNameTextField: UITextField!
    
    var myTimer: Timer!
    var activeField: UITextField!

    let forsinkelse = 3

    override func viewDidLoad() {
        super.viewDidLoad()

        self.NewNameTextField.delegate = self
        
        showUserInformation()

        /// Turn off keyboard when you press "Return"
        self.NewNameTextField.delegate = self
        self.OldNameTextField.delegate = self

        activity.hidesWhenStopped = true
        activity.style = .gray
        view.addSubview(activity)

        activity.startAnimating()

        OldNameTextField.text = Auth.auth().currentUser?.displayName

        activity.stopAnimating()
    }

    override func viewDidAppear(_ animated: Bool) {
        activity.startAnimating()
        userInfo.text = showUserInfo(startUp: false)
        activity.stopAnimating()
        // Observe keyboard change
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeUpdateName(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeUpdateName(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeUpdateName(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    @objc func keyboardWillChangeUpdateName(notification: NSNotification) {
        
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
        NewNameTextField.resignFirstResponder()
        OldNameTextField.resignFirstResponder()
    }
    
    @IBAction func SaveNewName(_ sender: UIBarButtonItem) {
        if (NewNameTextField.text?.count)! > 0 {
            activity.startAnimating()

            let region = NSLocale.current.regionCode?.lowercased()  // Returns the local region
            Auth.auth().languageCode = region!

            // Store the new username in Firebase
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = NewNameTextField.text
            changeRequest?.commitChanges { error in

                if error == nil {
                    self.OldNameTextField.text = self.NewNameTextField.text
                } else {
                    // Handle error
                    self.presentAlert(withTitle: NSLocalizedString("Error",
                                                                   comment: "UpdateUserNameViewVontroller.swift SaveNewName "),
                                      message: error?.localizedDescription as Any)
                    }
            }

            // Store the new username in CoreData
            let ok = updateNameCoreData(withEpost: (Auth.auth().currentUser?.email)!, withNavn: NewNameTextField.text!)

            if ok == false {
                let melding = "Unable to update the username in CoreData."
                presentAlert(withTitle: NSLocalizedString("Error", comment: "UpdateUserNameViewVontroller.swift SaveNewName "),
                             message: melding)
            }

            activity.stopAnimating()

            // Insert a short delay before the function "returnToSettings" is called
            myTimer = Timer.scheduledTimer(timeInterval: TimeInterval(forsinkelse), target: self, selector: #selector(showUserInformation), userInfo: nil, repeats: false)

        } else {
            let melding = NSLocalizedString("The username must have a value.", comment: "UpdateUserNameViewVontroller.swift SaveNewName ")
            presentAlert(withTitle: NSLocalizedString("Empty name", comment: "UpdateUserNameViewVontroller.swift SaveNewName "),
                         message: melding)
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
