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
import CoreData

class ViewController: UIViewController {

    var isSignIn : Bool = true
    
    var ePost : String = ""
    var passOrd : String = ""
    
    override func viewDidLoad() {
        
        getData()

        emailTextField.text = ePost
        passwordTextField.text = passOrd
        
        // let navn = Auth.auth().currentUser!.displayName!
        // print(navn)

        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBOutlet weak var signInSelector: UISegmentedControl!
    
    
    @IBOutlet weak var emailTextField: UITextField!
    
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBOutlet weak var signInButton: UIButton!
    
    
    @IBAction func signInSelectorChanged(_ sender: Any) {
        
        // Flip the boolean
        isSignIn = !isSignIn
        
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
                    
                    // let eMail = self.emailTextField.text
                    
                    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                    let entity =  NSEntityDescription.entity(forEntityName: "Entity", in: context)
                    
                    let newEntity = NSManagedObject(entity: entity!, insertInto: context)
                    newEntity.setValue(self.emailTextField.text, forKey: "eMail")
                    newEntity.setValue(self.passwordTextField.text, forKey: "passWord")

                    do {
                        try context.save()
                        print("Saved email and password")
                    } catch {
                        print("Failed saving")
                    }
                    
//                     self.performSegue(withIdentifier: "goToUpdateUserData", sender: self)
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
                        
                        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                        changeRequest?.displayName = "Jan Hovland"
                        
                        changeRequest?.commitChanges { error in
                            if error == nil {
                                print("User display name changed!")
                                self.dismiss(animated: false, completion: nil)
                            } else {
                                print("Error: \(error!.localizedDescription)")
                            }
                        }
                        
//                        self.performSegue(withIdentifier: "goToUpdateUserData", sender: self)
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
    
    func saveData(_ sender: Any) {
        
       let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
       let entity =  NSEntityDescription.entity(forEntityName: "entity", in: context)
        
        let newEntity = NSManagedObject(entity: entity!, insertInto: context)
        newEntity.setValue(emailTextField.text, forKey: "eMail")
        newEntity.setValue(passwordTextField.text, forKey: "passWord")

        
        do {
            try context.save()
            print("Saved")
        } catch {
            print("Failed saving")
        }
        
    }
    
    func getData() {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject]
            {
                
                if data.value(forKey: "eMail") != nil {
                    ePost = data.value(forKey: "eMail") as! String
                }
                
                if data.value(forKey: "passWord") != nil {
                    passOrd = data.value(forKey: "passWord") as! String
                }
               
            }
        
        } catch {
            print("Failed")
        }
    
    }
}
































