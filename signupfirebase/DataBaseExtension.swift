//
//  DataBaseExtension.swift
//  signupfirebase
//
//  Created by Jan  on 12/12/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import CoreData
import Firebase
import UIKit

extension UIViewController {
    func presentAlert(withTitle title: String, message: Any) {
        let alertController = UIAlertController(title: title, message: "\(message)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func presentAlertOption(withTitle title: String, message: Any) {
        let alertController = UIAlertController(title: title, message: "\(message)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Prøv en gang til", style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Registrer en ny bruker", style: .default, handler: { _ in CreateAccount() }))
        present(alertController, animated: true, completion: nil)
        
        // Denne funksjonen må være deklarert inne i "extension"
        func CreateAccount() {
            performSegue(withIdentifier: "gotoCreateAccount", sender: self)
        }
    }
    
    func saveCoreData(withEpost: String, withPassord: String, withUid: String, withLoggedIn: Bool, withName: String) -> Bool {
        var ok: Bool = false
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "User", in: context)
        
        let newEntity = NSManagedObject(entity: entity!, insertInto: context)
        
        newEntity.setValue(withEpost, forKey: "email")
        newEntity.setValue(withPassord, forKey: "password")
        newEntity.setValue(withUid, forKey: "uid")
        newEntity.setValue(withLoggedIn, forKey: "loggedin")
        newEntity.setValue(withName, forKey: "name")
        
        do {
            try context.save()
            ok = true
        } catch {
            print(error.localizedDescription)
        }
        
        return ok
    }
    
    func getCoreData() -> (String, String,String) {
        var ePost: String = ""
        var passWord: String = ""
        var name: String = ""
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "loggedin = true")
        
        do {
            let result = try context.fetch(request)
            
            if result.count > 0 {
                for data in result as! [NSManagedObject] {
                    if data.value(forKey: "email") != nil {
                        ePost = (data.value(forKey: "email") as? String)!
                    }
                    
                    if data.value(forKey: "password") != nil {
                        passWord = data.value(forKey: "password") as! String
                    }
                    
                    if data.value(forKey: "name") != nil {
                        name = data.value(forKey: "name") as! String
                    }
                    
                }
            }
            
        } catch {
            print(error.localizedDescription)
        }
        
        return (ePost, passWord,name)
    }
    
    func updateCoreData(withEpost: String, withLoggedIn: Bool) -> Bool {
        var ok: Bool = false
        
        // As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
        
        // We need to create a context from this container
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.predicate = NSPredicate(format: "email =  %@", withEpost)
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                ok = true
                for result in results as! [NSManagedObject] {
                    if (result.value(forKey: "email") as? String) != nil {
                        if let loggedin = result.value(forKey: "loggedin") as? Bool {
                            if loggedin != withLoggedIn {
                                result.setValue(withLoggedIn, forKey: "loggedin")
                                do {
                                    try context.save()
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return ok
    }
    
    func findCoreData(withEpost: String) -> Bool {
        var ok: Bool = false
        
        // As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
        
        // We need to create a context from this container
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.predicate = NSPredicate(format: "email =  %@", withEpost)
        
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                ok = true
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return ok
    }
    
    func findPasswordCoreData(withEpost: String) -> String {
        var password: String = ""
        
        // As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return "" }
        
        // We need to create a context from this container
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.predicate = NSPredicate(format: "email =  %@", withEpost)
        
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if (result.value(forKey: "password") as? String) != nil {
                        password = result.value(forKey: "password") as! String
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return password
    }
    
    func updateNameCoreData(withEpost: String, withNavn: String) -> Bool {
        var ok: Bool = false
        
        // As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
        
        // We need to create a context from this container
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.predicate = NSPredicate(format: "email =  %@", withEpost)
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                ok = true
                for result in results as! [NSManagedObject] {
                    if (result.value(forKey: "name") as? String) != nil {
                        result.setValue(withNavn, forKey: "name")
                        do {
                            try context.save()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return ok
    }
    
    func updatePasswordCoreData(withEpost: String, withPassWord: String) -> Bool {
        var ok: Bool = false
        
        // As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
        
        // We need to create a context from this container
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.predicate = NSPredicate(format: "email =  %@", withEpost)
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                ok = true
                for result in results as! [NSManagedObject] {
                    if (result.value(forKey: "password") as? String) != nil {
                        result.setValue(withPassWord, forKey: "password")
                        do {
                            try context.save()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return ok
    }
    
    func updateEpostCoreData(withOldEpost: String, withNewEpost: String) -> Bool {
        var ok: Bool = false
        
        // As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
        
        // We need to create a context from this container
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.predicate = NSPredicate(format: "email =  %@", withOldEpost)
        
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                ok = true
                for result in results as! [NSManagedObject] {
                    if (result.value(forKey: "email") as? String) != nil {
                        result.setValue(withNewEpost, forKey: "email")
                        do {
                            try context.save()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return ok
    }
    
    func deleteAllCoreData() {
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
    
    func deleteUserCoreData(UserEmail: String) -> Bool {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        
        request.predicate = NSPredicate(format: "email =  %@", UserEmail)
        
        request.returnsObjectsAsFaults = false
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            print("deleting user with epost: \(UserEmail)")
            try context.execute(deleteRequest)
            return true
            
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    func resetLoggedIinCoreData() -> Bool {
        var ok: Bool = false
        
        // As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
        
        // We need to create a context from this container
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.predicate = NSPredicate(format: "loggedin = true")
        
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                ok = true
                for result in results as! [NSManagedObject] {
                    if (result.value(forKey: "loggedin") as? Bool) != nil {
                        result.setValue(false, forKey: "loggedin")
                        do {
                            try context.save()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            } else {
                ok = true
            }
            
        } catch {
            print(error.localizedDescription)
        }
        
        return ok
    }
    
    func showUserInfo(startUp: Bool) -> String {
        let value = getCoreData()
        let email = value.0
        let name = value.2
        
        if email.count > 0,
            name.count > 0 {
            if startUp == false {
                return name +  " (" + email + ")."
            } else {
                return "Please log in to Firebase."
            }
        } else {
            return ""
        }
    }
    
    // Firebase database
    
    func SavePostFiredata(uid: String, username: String, photoURL: String, text: String) {
    
        let dataBase = Database.database().reference().child("posts").childByAutoId()
    
        let postObject = [
                         "author": [
                         "uid": uid,
                         "username": username,
                         "photoURL": photoURL
            ],
            "text":  text,
            "timestamp": [".sv": "timestamp"]
            ] as [String: Any]
    
        dataBase.setValue(postObject, withCompletionBlock: { error, ref in
            if error == nil {
                self.dismiss(animated: true, completion: nil)
            } else {
                print(error as! String)
            }
        })
        
    }

    
    
    
    
}
