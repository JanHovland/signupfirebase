//
//  ViewController.swift
//  signupfirebase
//
//  Created by Jan  on 02/11/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ViewController: UIViewController {

    var isSignIn : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBOutlet weak var signInSelector: UISegmentedControl!
    
    
    @IBOutlet weak var emailTextField: UITextField!
    
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBOutlet weak var signInButton: UIButton!
    
    
    @IBAction func signInSelectorChanged(_ sender: Any) {
        
        // Flip the boolean
        // isSignIn = !isSignIn
        
    }
    
    
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        
        // TODO: Do some validation on the email and password
        // print(emailTextField.text as Any)
        //
        // print(passwordTextField.text as Any)
        
        print(isSignIn)

        if let email = emailTextField.text, let pass = passwordTextField.text {
            
            // Check if it is sign in or register
            if isSignIn {
                // Sign in the user with Firebase
                
                Auth.auth().signIn(withEmail: email, password: pass) { (user, error) in
                // Check that user isn't nil
                    
                if  user != nil {
                    // User is found, go to home screen
                    self.performSegue(withIdentifier: "goToUpdateUserData", sender: self)
                } else {
                    // Error: check error and show message
                }
                    
            }
                
            } else {
                // Register the user with Firebase
                
                Auth.auth().createUser(withEmail: email, password: pass) { (user, error) in
                // Check that user isn't nil
                    
                    if  user != nil {
                        // User is found, go to home screen
                        self.performSegue(withIdentifier: "goToUpdateUserData", sender: self)
                    }
                }
                    
            }
            
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Dismiss the keyboard when the view is tapped on
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    @IBAction func cancelPost(_ sender: Any) {
        
        // Dismiss the popover
        presentingViewController?.dismiss(animated: true, completion: nil)
        
        
    }
    
    
    
}

