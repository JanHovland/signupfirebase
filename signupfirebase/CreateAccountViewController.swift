//
//  CreateAccountViewController.swift
//  signupfirebase
//
//  Created by Jan  on 12/11/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import CoreData

class CreateAccountViewController: UIViewController {

    @IBOutlet weak var eMailCreateAccountTextField: UITextField!
    @IBOutlet weak var nameCreateAccountTextField: UITextField!
    @IBOutlet weak var passwordCreateAccountTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        eMailCreateAccountTextField.text = ""
        nameCreateAccountTextField.text = ""
        passwordCreateAccountTextField.text = ""
    }
    
    @IBAction func SaveAccount(_ sender: UIBarButtonItem) {
        
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
                self.presentAlert(withTitle: "Error", message: "Du må legge inn Epost, Navn. Passordet må ha minst 6 tegn")
            } else {
                self.presentAlert(withTitle: "Error", message: "Du må legge inn Epost og Navn")
            }
            
        }
    }
    
}

