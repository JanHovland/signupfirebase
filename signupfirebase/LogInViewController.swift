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

class LogInViewController: UIViewController, UITextFieldDelegate {

    // For å finne uid, må du først logge inn med epost og passord.
    // Derfor kan du ikke lage en funksjon som henter uid!
    //   uid for      jho.hovland@gmail.com = MnYNNQNIJUgSXZhpKlk3TZaT2YJ3
    //   uid for      jan.hovland@lyse.net  = dT1YafDXgshYq6kAiIphTabMLwH2

    @IBOutlet weak var activity: UIActivityIndicatorView!
   
    @IBOutlet weak var eMailLoginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let ePost = "jan.hovland@lyse.net"
        let passOrd = "qwerty"
        
        // Test for å finne antall
        let antall = finnPost(withEpost: ePost)
        print(antall)

        // Test for å oppdatere en email med
        let ok = updateData(withEpost: ePost, withLoggedIn: true)
        print(ok)
        
        // Test for å lagre en post
        let ePost1 = "jho.hovland@gmail.com"
        let uid1 = "MnYNNQNIJUgSXZhpKlk3TZaT2YJ3"
        let ok1 = saveData(withEpost: ePost1, withPassord: passOrd, withUid : uid1, withLoggedIn: false)
        print("ok fra saveData: \(ok1)")
        
        eMailLoginTextField.delegate = self
        passwordTextField.delegate = self
        
        activity.hidesWhenStopped = true
        activity.style = .gray
        view.addSubview(activity)
        
        activity.startAnimating()

        // Henter sist brukte eMail og Password der CoreData sin "loggedIn" = true
//         getData(ResetLoggedIn: true)

        eMailLoginTextField.text = ePost
//        passwordTextField.text = passOrd
        
        print("Verdien til ePost fra viewDidLoad: \(ePost)")
        
        activity.stopAnimating()

        if ePost.count > 0 {
            eMailLoginTextField.text = ePost
        }
 
//        if passOrd.count > 0 {
//            passwordTextField.text = passOrd
//        }

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

//        ePost = eMailLoginTextField.text!
//        passOrd = passwordTextField.text!
        
        // Sjekk om eposten er registrert på en bruker
        let email = eMailLoginTextField.text
        let pass = passwordTextField.text

        if email!.count > 0,
            pass!.count >= 6 {
            
            self.activity.startAnimating()
            
            Auth.auth().signIn(withEmail: email!, password: pass!) { (user, error) in
            
                // Check that error isn't nil
                
                if error == nil {
       
                    // Sletter alle data i CoreData
                    // self.deleteAllData()
     
                    // Sjekk om en skal legge inn en ny post i CoreData
                    
//                     self.getData(ResetLoggedIn: true)
                    
                    
                    
                    
//                    if ePost != self.eMailLoginTextField.text! {

//                    print(ePost)
//                        ePost = self.eMailLoginTextField.text!
//                        passOrd = self.passwordTextField.text!
//                        uid = self.hentUID(eMail: ePost, passWord: passOrd)
                    
                        self.getData(ResetLoggedIn: true)
                    
//                        loggedIn = true

                    
// Sjekk om denne ePost finner fra før -> update()
// Sjekk om denne ePost ikke finnes fra før -> saveData
                    
//                       print(ePost)
                    
                        // Lagrer epost og passord i Coredata
//                       self.saveData()
//                        self.updateData()
                        
                        self.activity.stopAnimating()
                        
//                    }
                    
                    self.performSegue(withIdentifier: "UpdateUserDataFromLogin", sender: self)
                    
                } else {
                    
//                    ePost = self.eMailLoginTextField.text!
//                    passOrd = self.passwordTextField.text!
                    
                    self.presentAlertOption(withTitle: "Error", message: error!.localizedDescription as Any)
                }
                
            }
            
            self.activity.stopAnimating()

        } else {
            
            let melding = "eMail må ha en verdi.\nPassword må være minst 6 tegn langt"
            
            self.presentAlert(withTitle: "Error", message: melding)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        eMailLoginTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
    
}

extension UIViewController {
    
    func presentAlert(withTitle title: String, message : Any) {
        let alertController = UIAlertController(title: title, message: "\(message)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        
    }

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
    
    func saveData(withEpost: String, withPassord: String, withUid : String, withLoggedIn: Bool) -> Bool {

        var ok: Bool = false
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let entity =  NSEntityDescription.entity(forEntityName: "User", in: context)
        
        let newEntity = NSManagedObject(entity: entity!, insertInto: context)
        
        newEntity.setValue(withEpost, forKey: "email")
        newEntity.setValue(withPassord, forKey: "password")
        newEntity.setValue(withUid, forKey: "uid")
        newEntity.setValue(withLoggedIn, forKey: "loggedin")

        do {
            try context.save()
            print("Saved ePost, passOrd, uid og loggedIn")
            ok = true
        } catch {
            print(error.localizedDescription)
        }
        
        return ok
        
    }
    
    func getData(ResetLoggedIn: Bool) {
        
        // Finner alle postene hvor "loggedin = true"
        // Dersom ResetLoggedIn = true, settes alle "loggedin" til false
        
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "loggedin = true")
        
        do {
            let result = try context.fetch(request)
            
            if result.count > 0 {
            
                for data in result as! [NSManagedObject] {
                
                    if data.value(forKey: "email") != nil {
//                        ePost = (data.value(forKey: "email") as? String)!
                    }
                
                    if data.value(forKey: "password") != nil {
//                        passOrd = data.value(forKey: "password") as! String
                    }
                
                    if data.value(forKey: "uid") != nil {
//                        uid = data.value(forKey: "uid") as! String
                    }
                
                    if data.value(forKey: "loggedin") != nil {
//                        loggedIn = data.value(forKey: "loggedin") as! Bool
                    }
                    
                    if ResetLoggedIn == true {
                        
//                        loggedIn = false
//                         updateData()
                        
                    }
                    
                }
            }
            
        } catch {
            print(error.localizedDescription)
        }
        
    }

    func updateData(withEpost: String, withLoggedIn: Bool) -> Bool {
        
        var ok: Bool = false
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false}
        
        //We need to create a context from this container
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
            request.predicate = NSPredicate(format: "email =  %@", withEpost)
        do
        {
            let results = try context.fetch(request)
            if results.count > 0 {
                ok = true
                for result in results as![NSManagedObject] {
                    if let email = result.value(forKey: "email") as? String {
                        print(email)
                        if let loggedin = result.value(forKey: "loggedin") as? Bool {
                            if loggedin != withLoggedIn {
                                result.setValue(withLoggedIn, forKey: "loggedin")
                                do {
                                    try context.save()
                                }
                                catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                    }
                
                }
            }
        }
        catch
        {
            print(error.localizedDescription)
        }
        
        return ok
        
    }
    
    func finnPost(withEpost: String) -> Int {
        
        var antall: Int = 0
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return 0 }
        
        //We need to create a context from this container
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.predicate = NSPredicate(format: "email =  %@", withEpost)
        
        do
        {
            let results = try context.fetch(request)
            antall = results.count
       }
        catch {
            print(error.localizedDescription)
        }

        return antall

    }

    func deleteAllData() {

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.returnsObjectsAsFaults = false

        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)

        do {
           print("deleting all content")
           try context.execute(deleteRequest)

        } catch {
            print(error.localizedDescription)
        }

    }

}

