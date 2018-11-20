//
//  UpdateUserNameViewController.swift
//  signupfirebase
//
//  Created by Jan  on 18/11/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import UIKit
import Firebase

class UpdateUserNameViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var OldNameTextField: UITextField!
    @IBOutlet weak var NewNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .gray
        view.addSubview(activityIndicator)
        
        // Define layout constraint for the activityIndicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([(activityIndicator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25.0)),
                                     (activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor))])
        
        activityIndicator.startAnimating()
      
        Auth.auth().signIn(withEmail: ePost, password: passOrd) { (user, error) in
            
            if error == nil {
                
                // Finner det gamle navnet
                
                let user = Auth.auth().currentUser
                
                if let user = user {
                    self.OldNameTextField.text = user.displayName
                }
            } else {
                // Håndtere error
                self.presentAlert(withTitle: "Error", message: error?.localizedDescription as Any)
            }
        }
        
        activityIndicator.stopAnimating()
    }
    
    @IBAction func SaveNewName(_ sender: UIBarButtonItem) {
    
        if (self.NewNameTextField.text?.count)! > 0 {
            
            activityIndicator.startAnimating()
            
            Auth.auth().signIn(withEmail: ePost, password: passOrd) { (user, error) in

                if error == nil {
                    
                    // Legger inn det nye navnet
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = self.NewNameTextField.text
                    changeRequest?.commitChanges { (error) in
                        
                        if error == nil {
                            self.OldNameTextField.text = self.NewNameTextField.text
                        } else {
                            // Håndtere error
                            self.presentAlert(withTitle: "Error", message: error?.localizedDescription as Any)
                        }
                        
                    }
                } else {
                    // Håndtere error
                    self.presentAlert(withTitle: "Error", message: error?.localizedDescription as Any)
                }
            }
            
            activityIndicator.stopAnimating()
            
        } else {
            // Legge ut varsel
            let melding = "Det nye navnet må ha en verdi."
            self.presentAlert(withTitle: "Tomt navn", message: melding)

        }
    }
    
}
