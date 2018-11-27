//
//  CreateAccountViewController.swift
//  signupfirebase
//
//  Created by Jan  on 12/11/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import UIKit
import Firebase
// import FirebaseAuth
import CoreData

class CreateAccountViewController: UIViewController {
 
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    @IBOutlet weak var nameCreateAccountTextField: UITextField!
    @IBOutlet weak var eMailCreateAccountTextField: UITextField!
    @IBOutlet weak var passwordCreateAccountTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activity.hidesWhenStopped = true
        activity.style = .gray
        view.addSubview(activity)
        
//        eMailCreateAccountTextField.text = ePost
//        passwordCreateAccountTextField.text = passOrd
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
       
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Dismiss the keyboard when the view is tapped on
        eMailCreateAccountTextField.resignFirstResponder()
        nameCreateAccountTextField.resignFirstResponder()
        passwordCreateAccountTextField.resignFirstResponder()
    }
    
    @IBAction func SaveAccount(_ sender: UIBarButtonItem) {

        activity.startAnimating()
        
        // Dismiss the keyboard when the Save button is tapped on
        eMailCreateAccountTextField.resignFirstResponder()
        nameCreateAccountTextField.resignFirstResponder()
        passwordCreateAccountTextField.resignFirstResponder()

        
        let email = eMailCreateAccountTextField.text
        let name = nameCreateAccountTextField.text
        let pass = passwordCreateAccountTextField.text
        
        if email!.count > 0,
           name!.count > 0,
           pass!.count >= 6 {
        
           // Register the user with Firebase
            Auth.auth().createUser(withEmail: email!, password: pass!) {
              (user, error) in

              if error == nil {
                
                  // Lagre epost og  passord
                
//                  ePost = email!
//                  passOrd = pass!
//                
                  // self.saveData()
                
                  // Legg inn Navnet på brukeren
                  let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                  changeRequest?.displayName = name
                
                  changeRequest?.commitChanges { error in
                     if error == nil {
                        print("User display name changed!")
                        self.dismiss(animated: false, completion: nil)
                     } else {
                        print("Error: \(error!.localizedDescription)")
                     }
                   }
                
                   self.performSegue(withIdentifier: "UpdateUserDataFromCreateAccount", sender: self)

              } else {
                
                  self.presentAlert(withTitle: "Error", message: error!.localizedDescription as Any)
                
              }
           }

        } else {
            
            if pass!.count < 6 {
                self.presentAlert(withTitle: "Error", message: "Legg inn verdier i alle feltene. \nPassordet må ha minst 6 tegn")
            } else { 
                self.presentAlert(withTitle: "Error", message: "Legg inn verdier i alle feltene")
            }
            
        }
        
        activity.stopAnimating()
    }
    
    
}

