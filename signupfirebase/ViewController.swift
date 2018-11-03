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
    
    
    @IBOutlet weak var signInLabel: UILabel!
    
    
    @IBOutlet weak var emailTextField: UITextField!
    
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBOutlet weak var signInButton: UIButton!
    
    
    @IBAction func signInSelectorChanged(_ sender: Any) {
        
        // Flip the boolean
        isSignIn = !isSignIn
        
        // Check the bool and set the labels and button
        if isSignIn {
            signInLabel.text = "Sign In"
            signInButton.setTitle("Sign In", for: .normal)
        } else {
            signInLabel.text = "Register"
            signInButton.setTitle("Register", for: .normal)
        }
        
    }
    
    
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        
        // TODO: Do some validation on the email and password
        // print(emailTextField.text as Any)
        //
        // print(passwordTextField.text as Any)
        
        if let email = emailTextField.text, let pass = passwordTextField.text {
            
            // Check if it is sign in or register
            if isSignIn {
                // Sign in the user with Firebase
                
                Auth.auth().signIn(withEmail: email, password: pass) { (user, error) in
                // Check that user isn't nil
                    
                    if let u = user {
                        // User is found, go to home screen
                        self.performSegue(withIdentifier: "goToHome", sender: self)
                    } else {
                        // Error: check error and show message
                    }
                    
                }
                
            } else {
                // Register the user with Firebase
                
                Auth.auth().createUser(withEmail: email, password: pass) { (user, error) in
                // Check that user isn't nil
                    
                    if let u = user {
                        // User is found, go to home screen
                        self.performSegue(withIdentifier: "goToHome", sender: self)
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
    
    
    
    
}

