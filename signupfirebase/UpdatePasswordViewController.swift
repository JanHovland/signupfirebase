//
//  UpdatePasswordViewController.swift
//  signupfirebase
//
//  Created by Jan  on 18/11/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import UIKit
import Firebase

// gotoSettingsFromUpdatePassword

class UpdatePasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    
    var myTimer: Timer!
    
    // Setter en "constant" forsinkelse etter at en trykker på "Save"
    let forsinkelse = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newPasswordTextField.delegate = self

        self.activity.hidesWhenStopped = true
        self.activity.style = .gray
        view.addSubview(activity)
        
        self.activity.startAnimating()
        
        Auth.auth().signIn(withEmail: ePost, password: passOrd) { (user, error) in
            
            if error == nil {
                
                // Finner epost
                
                let user = Auth.auth().currentUser
                
                if user != nil {
                    self.oldPasswordTextField.isSecureTextEntry = true
                    self.oldPasswordTextField.borderStyle = .none
                    self.oldPasswordTextField.text = passOrd
                }
            } else {
                // Håndtere error
                self.presentAlert(withTitle: "Error", message: error?.localizedDescription as Any)
            }
            
            self.activity.stopAnimating()
        }
        
    }

    @IBAction func SaveNewPassword(_ sender: Any) {
    
    
    
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        newPasswordTextField.resignFirstResponder()
        return true
    }

    
}
