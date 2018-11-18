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
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    @IBOutlet weak var eMailLoginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
       super.viewDidLoad()
       activity?.isHidden = true
        
       activity?.isHidden = false
       activity?.startAnimating()
        
        // Henter sist brukte eMail og Password
        getData()
        
        print("Verdien til ePost fra getData: \(ePost)")

        
        // Sletter alle postene i databasen
        deleteAllData()
        
       activity?.isHidden = true
       activity?.stopAnimating()
        
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

        ePost = eMailLoginTextField.text!
        passOrd = passwordTextField.text!
        
        // Sjekk om eposten er registrert på en bruker
        let email = eMailLoginTextField.text
        let pass = passwordTextField.text
        
        if email!.count > 0,
            pass!.count >= 6 {
            
            self.activity?.isHidden = false
            self.activity?.startAnimating()
            
            Auth.auth().signIn(withEmail: email!, password: pass!) { (user, error) in
            
                // Check that error isn't nil
                
                if error == nil {
       
                        // Sletter alle data i CoreData
                        self.deleteAllData()
                    
                        ePost = self.eMailLoginTextField.text!
                        passOrd = self.passwordTextField.text!
                    
                        // Lagrer epost og passord i Coredata
                        self.saveData()
                    
                        self.activity?.isHidden = true
                        self.activity?.stopAnimating()
                   
                    self.performSegue(withIdentifier: "UpdateUserDataFromLogin", sender: self)
                } else {
                    
                    ePost = self.eMailLoginTextField.text!
                    passOrd = self.passwordTextField.text!
                    
                    self.presentAlertOption(withTitle: "Error", message: error!.localizedDescription as Any)
                }
                
            }
            
            self.activity?.isHidden = true
            self.activity?.stopAnimating()

        } else {
            
            let melding = "eMail må ha en verdi.\nPassword må være minst 6 tegn langt"
            
            self.presentAlert(withTitle: "Error", message: melding)
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

    func presentAlertOption(withTitle title: String, message : Any) {
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
    
    func deleteAllData() {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
        request.returnsObjectsAsFaults = false
   
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
           print("deleting all content")
           try context.execute(deleteRequest)
            
        } catch {
            print(error.localizedDescription)
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



