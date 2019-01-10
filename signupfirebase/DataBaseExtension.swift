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

//var timer:Timer?
//var timeLeft = 0

extension UIViewController {
    
//    func countDownTimer(seconds: Int) {
//        
//        timeLeft = seconds
//        
//        // The timer doesn’t start immediately. Until it starts, the timer property is nil.
//        // At some point the game has started, and we start the timer:
//    
//        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerFires), userInfo: nil, repeats: true)
//   
//        print("timeLeft = \(timeLeft)")
//        
//
//    }
//
//    @objc func onTimerFires()
//    {
//        timeLeft -= 1
//        
//        if timeLeft <= 0 {
//            timer!.invalidate()
//            timer = nil
//        }
//        
//    }
//
    
    
    
    
    
    func presentAlert(withTitle title: String,
                      message: Any) {
        
        let alertController = UIAlertController(title: title,
                                                message: "\(message)",
                                                preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"),
                                                style: .default,
                                                handler: nil))
        
        present(alertController,
                animated: true,
                completion: nil)
    }

    func presentAlertOption(withTitle title: String,
                            message: Any) {
        
        let alertController = UIAlertController(title: title,
                                                message: "\(message)",
                                                preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Try one more time",
                                                comment: "DataBaseExtension.swift presentAlertOption"),
                                                style: .default,
                                                handler: nil))
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Add a new user",
                                                comment: "DataBaseExtension.swift presentAlertOption"),
                                                style: .default,
                                                handler: { _ in CreateAccount() }))
        
        present(alertController,
                animated: true,
                completion: nil)

        // Denne funksjonen må være deklarert inne i "extension"
        func CreateAccount() {
            performSegue(withIdentifier: "gotoCreateAccount",
                         sender: self)
        }
    }

    func saveCoreData(withEpost: String,
                      withPassord: String,
                      withUid: String,
                      withLoggedIn: Bool,
                      withName: String) -> Bool {
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

    func getCoreData() -> (String, String, String, String) {
        var ePost: String = ""
        var passWord: String = ""
        var name: String = ""
        var uid: String = ""

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "loggedin = true")

        do {
            let result = try context.fetch(request)

            if result.count > 0 {
                for data in result as! [NSManagedObject] {
                    if data.value(forKey: "uid") != nil {
                        uid = data.value(forKey: "uid") as! String
                    }

                    if data.value(forKey: "email") != nil {
                        ePost = (data.value(forKey: "email") as? String)!
                    }

                    if data.value(forKey: "name") != nil {
                        name = data.value(forKey: "name") as! String
                    }

                    if data.value(forKey: "password") != nil {
                        passWord = data.value(forKey: "password") as! String
                    }
                }
            }

        } catch {
            print(error.localizedDescription)
        }

        return (uid, ePost, name, passWord)
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
        //  0 = uid  1 = ePost  2 = name  3 = passWord)
        let value = getCoreData()

        let email = value.1
        let name = value.2

        if email.count > 0,
            name.count > 0 {
            if startUp == false {
                return name + " (" + email + ")."
            } else {
                return NSLocalizedString("Please log in to Firebase.",
                                         comment: "DataBaseExtension.swift showUserInfo.")
            }
        } else {
            return ""
        }
    }

    // Firebase database

    func SavePersonFiredata(uid: String,
                            username: String,
                            email: String,
                            name: String,
                            address: String,
                            dateOfBirth: String,
                            gender: String) {
        if uid.count > 0,
            username.count > 0,
            email.count > 0,
            name.count > 0,
            address.count > 0,
            dateOfBirth.count > 0,
            gender.count > 0 {
            let dataBase = Database.database().reference().child("person").childByAutoId()

            let postObject = [
                "author": [
                    "uid": uid,
                    "username": username,
                    "email": email,
                ],
                
                "personData": [
                    "name": name,
                    "address": address,
                    "dateOfBirth": dateOfBirth,
                    "gender": gender,
                ],
                
                "timestamp": [".sv": "timestamp"],

            ] as [String: Any]

            dataBase.setValue(postObject, withCompletionBlock: { error, _ in
                if error == nil {
                    self.dismiss(animated: true, completion: nil)
                    self.presentAlert(withTitle: NSLocalizedString("Saving in Firebase",
                                                                   comment: "DataBaseExtension.swift SavePersonFiredata"),
                                      message: "\r\n" + NSLocalizedString("Data are saved in Firebase.",
                                                                   comment: "DataBaseExtension.swift SavePersonFiredata"))
                } else {
                    print(error!.localizedDescription)
                }
            })
        } else {
            let melding = "\r\n" + NSLocalizedString("Every field must be filled.",
                                            comment: "DataBaseExtension.swift SavePersonFiredata")
            
            self.presentAlert(withTitle: NSLocalizedString("Error",
                                                           comment: "DataBaseExtension.swift SavePersonFiredata"),
                                                           message: melding)
        }
    }
}
