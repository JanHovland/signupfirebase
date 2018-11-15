//
//  LogInViewController.swift
//  signupfirebase
//
//  Created by Jan  on 11/11/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import UIKit
import Firebase
import CoreData

var ePost : String = ""
var passOrd : String = ""

class LogInViewController: UIViewController {
    
    
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
       
       // Henter sist brukte eMail og Password
       getData()
        
       if ePost.count > 0 {
          eMailLoginTextField.text = ePost
       }
 
       if passOrd.count > 0 {
           passwordTextField.text = passOrd
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
                    self.saveData()
                    
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
    
    func saveData() {

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let entity =  NSEntityDescription.entity(forEntityName: "Entity", in: context)
        
        let newEntity = NSManagedObject(entity: entity!, insertInto: context)
        newEntity.setValue(ePost, forKey: "eMail")
        newEntity.setValue(passOrd, forKey: "passWord")
        do {
            try context.save()
            print("Saved email and password")
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
                    ePost = (data.value(forKey: "eMail") as? String)!
                    
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



