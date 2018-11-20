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

    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    @IBOutlet weak var OldNameLabel: UILabel!
    @IBOutlet weak var NewNameTextField: UITextField!
    
    var myTimer: Timer!
    
    // Setter en forsinkelse etter at en trykker på "Save" 
    let forsinkelse = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activity.hidesWhenStopped = true
        activity.style = .gray
        view.addSubview(activity)
        
        // Define layout constraint for the activityIndicator
        activity.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([(activity.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25.0)),
                                     (activity.centerXAnchor.constraint(equalTo: view.centerXAnchor))])
        
        activity.startAnimating()
      
        Auth.auth().signIn(withEmail: ePost, password: passOrd) { (user, error) in
            
            if error == nil {
                
                // Finner det gamle navnet
                
                let user = Auth.auth().currentUser
                
                if let user = user {
                    self.OldNameLabel.text = user.displayName
                }
            } else {
                // Håndtere error
                self.presentAlert(withTitle: "Error", message: error?.localizedDescription as Any)
            }
        }
        
        activity.stopAnimating()
    }
    
    @IBAction func SaveNewName(_ sender: UIBarButtonItem) {
    
        if (self.NewNameTextField.text?.count)! > 0 {
            
            activity.startAnimating()
            
            Auth.auth().signIn(withEmail: ePost, password: passOrd) { (user, error) in

                if error == nil {
                    
                    // Legger inn det nye navnet
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = self.NewNameTextField.text
                    changeRequest?.commitChanges { (error) in
                        
                        if error == nil {
                            self.OldNameLabel.text = self.NewNameTextField.text
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
            
            activity.stopAnimating()
 
            // Legg inn en liten forsinkelse før funksjonen "returnToSettings" kalles
            myTimer = Timer.scheduledTimer(timeInterval: TimeInterval(forsinkelse), target: self, selector: #selector(returnToSettings), userInfo: nil, repeats: false)
            
        } else {
            // Legge ut varsel
            let melding = "Det nye navnet må ha en verdi."
            self.presentAlert(withTitle: "Tomt navn", message: melding)

        }
    }
    
    @objc func returnToSettings() {
        performSegue(withIdentifier: "BackToSettingsTableViewController", sender: self)
        myTimer.invalidate()
    }
    
}
