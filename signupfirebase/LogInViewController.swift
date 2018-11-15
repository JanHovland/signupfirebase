//
//  LogInViewController.swift
//  signupfirebase
//
//  Created by Jan  on 11/11/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import UIKit
import Firebase
// import FirebaseAuth
import CoreData

class LogInViewController: UIViewController {
    
    var ePost : String = ""
    var passOrd : String = ""
    
    
    @IBOutlet weak var NextButton: UIBarButtonItem!
    
    @IBOutlet weak var eMailLoginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // Aktiverer NextButton ved: "Editing Did Begin"
    @IBAction func eMailText(_ sender: Any) {
        NextButton.isEnabled  = true
    }
       
    override func viewDidLoad() {
       super.viewDidLoad()
        
       // Deaktiverer NextButton ved oppstart
       NextButton.isEnabled  = false
        
        
       // getData()
  
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject]
            {
                
                if data.value(forKey: "eMail") != nil {
                    eMailLoginTextField.text = data.value(forKey: "eMail") as? String
                    
                }
                
                if data.value(forKey: "passWord") != nil {
                    passwordTextField.text = data.value(forKey: "passWord") as? String
                }
                
            }
            
        } catch {
            print("Failed")
        }

        
        
        
    }
    
    // Når en kommer tilbake til skjermbildet
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Dismiss the keyboard when the view is tapped on
        eMailLoginTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    @IBAction func NextButtonTapped(_ sender: UIBarButtonItem) {
 
        // Dismiss the keyboard when the Next button is tapped on
        eMailLoginTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        // Sjekk om eposten er registrert på en bruker
        
        let email = eMailLoginTextField.text
        let pass = passwordTextField.text
        
        if email!.count > 0,
            pass!.count >= 6 {
            
            Auth.auth().signIn(withEmail: email!, password: pass!) { (user, error) in
            
                // Check that user isn't nil
                
                if error == nil {
                    
                    // Lagrer epost og passord i Coredata
                    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                    let entity =  NSEntityDescription.entity(forEntityName: "Entity", in: context)
                    
                    let newEntity = NSManagedObject(entity: entity!, insertInto: context)
                    newEntity.setValue(self.eMailLoginTextField.text, forKey: "eMail")
                    newEntity.setValue(self.passwordTextField.text, forKey: "passWord")
                    do {
                        try context.save()
                        print("Saved email and password")
                    } catch {
                        print("Failed saving")
                    }
                    
                    self.performSegue(withIdentifier: "UpdateUserDataFromLoginEmail", sender: self)
                } else {
                      self.presentAlertChoise(withTitle: "Error", message: error!.localizedDescription as Any)
                }
                
            }
            
        }
    }
}

extension UIViewController {
    
    func presentAlert(withTitle title: String, message : Any) {
        let alertController = UIAlertController(title: title, message: "\(message)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        
    }
}

extension UIViewController {

    func presentAlertChoise(withTitle title: String, message : Any) {
        let alertController = UIAlertController(title: title, message: "\(message)", preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "Try again", style: .default, handler: nil))

        alertController.addAction(UIAlertAction(title: "CreateAccount", style: .default, handler: { action in
            CreateAccount()
            // self.performSegue(withIdentifier: "CreateAccount", sender: self)
        }))

        self.present(alertController, animated: true, completion: nil)

        
        // Denne funksjonen må være deklarert inne i "extension"
        func CreateAccount() {
            self.performSegue(withIdentifier: "CreateAccount", sender: self)
        }

    }
    
//    func saveData(_ sender: Any) {
//
//        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//        let entity =  NSEntityDescription.entity(forEntityName: "entity", in: context)
//
//        let newEntity = NSManagedObject(entity: entity!, insertInto: context)
//
//        let ePost = eMailLoginTextField.text
//
//        newEntity.setValue(eMailLoginTextField.text, forKey: "eMail")
//        newEntity.setValue(passwordTextField.text, forKey: "passWord")
//
//
//        do {
//            try context.save()
//            print("Saved")
//        } catch {
//            print("Failed saving")
//        }
//
//    }
    
//    func getData() {
//        
//        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
//        request.returnsObjectsAsFaults = false
//        
//        do {
//            let result = try context.fetch(request)
//            for data in result as! [NSManagedObject]
//            {
//                
//                if data.value(forKey: "eMail") != nil {
//                    let ePost = data.value(forKey: "eMail") as? String
//                    
//                }
//                
//                if data.value(forKey: "passWord") != nil {
//                    let passOrd = data.value(forKey: "passWord") as! String
//                }
//                
//            }
//            
//        } catch {
//            print("Failed")
//        }
//        
//    }

 }



