//
//  UpdatePasswordViewController.swift
//  signupfirebase
//
//  Created by Jan  on 18/11/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import UIKit
import Firebase

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
    
        self.activity.startAnimating()
       
        Auth.auth().currentUser?.updatePassword(to: newPasswordTextField.text!) { (error) in
            
            if error != nil {
                self.presentAlertOption(withTitle: "Error", message: error!.localizedDescription as Any)
            } else {
                
                // Sletter CoreData
                self.deleteAllData()
                
                // Lagrer passord i Coredata
                passOrd = self.newPasswordTextField.text!
                
                self.saveData()
                
                // Legg inn en liten forsinkelse før funksjonen "returnToLogin" kalles
                self.myTimer = Timer.scheduledTimer(timeInterval: TimeInterval(self.forsinkelse), target: self, selector: #selector(self.returnToLogin), userInfo: nil, repeats: false)

            }
            
        }
    
        self.activity.stopAnimating()
    }
    
    @objc func returnToLogin() {
        performSegue(withIdentifier: "BackToLoginViewController", sender: self)
        myTimer.invalidate()
        print(ePost)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        newPasswordTextField.resignFirstResponder()
        return true
    }

    
}
