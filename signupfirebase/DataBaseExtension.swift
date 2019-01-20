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
            let melding = error.localizedDescription
            self.presentAlert(withTitle: NSLocalizedString("Error", comment: "DataBaseExtension.swift saveCoreData"),
                              message: melding)
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
            let melding = error.localizedDescription
            self.presentAlert(withTitle: NSLocalizedString("Error", comment: "DataBaseExtension.swift getCoreData"),
                              message: melding)
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
                                    let melding = error.localizedDescription
                                    self.presentAlert(withTitle: NSLocalizedString("Error", comment: "DataBaseExtension.swift updateCoreData"),
                                                      message: melding)
                                }
                            }
                        }
                    }
                }
            }
        } catch {
            let melding = error.localizedDescription
            self.presentAlert(withTitle: NSLocalizedString("Error", comment: "DataBaseExtension.swift updateCoreData"),
                              message: melding)
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
            let melding = error.localizedDescription
            self.presentAlert(withTitle: NSLocalizedString("Error", comment: "DataBaseExtension.swift findCoreData"),
                              message: melding)
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
            let melding = error.localizedDescription
            self.presentAlert(withTitle: NSLocalizedString("Error", comment: "DataBaseExtension.swift findPasswordCoreData"),
                              message: melding)
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
                            let melding = error.localizedDescription
                            self.presentAlert(withTitle: NSLocalizedString("Error", comment: "DataBaseExtension.swift updateNameCoreData"),
                                              message: melding)
                        }
                    }
                }
            }
        } catch {
            let melding = error.localizedDescription
            self.presentAlert(withTitle: NSLocalizedString("Error", comment: "DataBaseExtension.swift updateNameCoreData"),
                              message: melding)
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
                            let melding = error.localizedDescription
                            self.presentAlert(withTitle: NSLocalizedString("Error", comment: "DataBaseExtension.swift updatePasswordCoreData"),
                                              message: melding)
                        }
                    }
                }
            }
        } catch {
            let melding = error.localizedDescription
            self.presentAlert(withTitle: NSLocalizedString("Error", comment: "DataBaseExtension.swift updatePasswordCoreData"),
                              message: melding)
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
                            let melding = error.localizedDescription
                            self.presentAlert(withTitle: NSLocalizedString("Error", comment: "DataBaseExtension.swift updateEpostCoreData"),
                                              message: melding)
                        }
                    }
                }
            }
        } catch {
            let melding = error.localizedDescription
            self.presentAlert(withTitle: NSLocalizedString("Error", comment: "DataBaseExtension.swift updateEpostCoreData"),
                              message: melding)
        }

        return ok
    }

    func deleteAllCoreData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.returnsObjectsAsFaults = false

        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)

        do {
            try context.execute(deleteRequest)

        } catch {
            let melding = error.localizedDescription
            self.presentAlert(withTitle: NSLocalizedString("Error", comment: "DataBaseExtension.swift deleteAllCoreData"),
                              message: melding)
        }
    }

    func deleteUserCoreData(UserEmail: String) -> Bool {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")

        request.predicate = NSPredicate(format: "email =  %@", UserEmail)

        request.returnsObjectsAsFaults = false

        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)

        do {
            try context.execute(deleteRequest)
            return true

        } catch {
            let melding = error.localizedDescription
            self.presentAlert(withTitle: NSLocalizedString("Error", comment: "DataBaseExtension.swift deleteUserCoreData"),
                              message: melding)
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
                            let melding = error.localizedDescription
                            self.presentAlert(withTitle: NSLocalizedString("Error", comment: "DataBaseExtension.swift resetLoggedInCoreData"),
                                              message: melding)
                        }
                    }
                }
            } else {
                ok = true
            }

        } catch {
            let melding = error.localizedDescription
            self.presentAlert(withTitle: NSLocalizedString("Error", comment: "DataBaseExtension.swift resetLoggedInCoreData"),
                              message: melding)
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
            //     return name + " (" + email + ")."
                return email
            } else {
                return NSLocalizedString("Please log in to Firebase.",
                                         comment: "DataBaseExtension.swift showUserInfo.")
            }
        } else {
            return ""
        }
    }
   
    func updatePersonFiredata(id: String,
                              uid: String,
                              username: String,
                              email: String,
                              address: String,
                              city: String,
                              dateOfBirth: String,
                              firstName: String,
                              gender: Int,
                              lastName: String,
                              phoneNumber: String,
                              postalCodeNumber: String) {
        if uid.count > 0,
            username.count > 0,
            email.count > 0,
            address.count > 0,
            city.count > 0,
            dateOfBirth.count > 0,
            firstName.count > 0,
            lastName.count > 0,
            phoneNumber.count > 0,
            postalCodeNumber.count > 0 {
            
            let dataBase = Database.database().reference().child("person" + "/" + id)
            
            let postObject = [
                "author": [
                    "uid": uid,
                    "username": username,
                    "email": email,
                ],
                
                "personData": [
                    "address": address,
                    "city": city,
                    "dateOfBirth": dateOfBirth,
                    "firstName": firstName,
                    "gender": gender,
                    "lastName": lastName,
                    "phoneNumber": phoneNumber,
                    "postalCodeNumber": postalCodeNumber
                ],

                "timestamp": [".sv": "timestamp"],
                
                ] as [String: Any]
            
            dataBase.setValue(postObject, withCompletionBlock: { error, _ in
                if error == nil {
                    self.dismiss(animated: true, completion: nil)
                    let title = NSLocalizedString("Update in Firebase",comment: "DataBaseExtension.swift updatePersonFiredata")
                    let message = "\r\n" + NSLocalizedString("Data are now updated in Firebase.", comment: "DataBaseExtension.swift updatePersonFiredata")
                    self.presentAlert(withTitle: title, message: message)
                } else {
                    let melding = error!.localizedDescription
                    self.presentAlert(withTitle: NSLocalizedString("Error", comment: "DataBaseExtension.swiftt savePersonFiredata"),
                                      message: melding)
                }
            })
        } else {
            let melding = "\r\n" + NSLocalizedString("Every field must be filled.",
                                                     comment: "DataBaseExtension.swift savePersonFiredata")
            
            self.presentAlert(withTitle: NSLocalizedString("Error",
                                                           comment: "DataBaseExtension.swift  savePersonFiredata"),
                              message: melding)
        }
    }
    
    func savePersonFiredata(uid: String,
                            username: String,
                            email: String,
                            address: String,
                            city: String,
                            dateOfBirth: String,
                            firstName: String,
                            gender: Int,
                            lastName: String,
                            phoneNumber: String,
                            postalCodeNumber: String) {
        if uid.count > 0,
            username.count > 0,
            email.count > 0,
            address.count > 0,
            city.count > 0,
            dateOfBirth.count > 0,
            firstName.count > 0,
            lastName.count > 0,
            phoneNumber.count > 0 {
                
            let dataBase = Database.database().reference().child("person").childByAutoId()
            
            let postObject = [
                "author": [
                    "uid": uid,
                    "username": username,
                    "email": email,
                ],
                
                "personData": [
                    "address": address,
                    "city": city,
                    "dateOfBirth": dateOfBirth,
                    "firstName": firstName,
                    "gender": gender,
                    "lastName": lastName,
                    "phoneNumber": phoneNumber,
                    "postalCodeNumber": postalCodeNumber
                ],
                
                "timestamp": [".sv": "timestamp"],
                
                ] as [String: Any]
            
            dataBase.setValue(postObject, withCompletionBlock: { error, _ in
                if error == nil {
                    self.dismiss(animated: true, completion: nil)
                    let title = NSLocalizedString("Save in Firebase",comment: "DataBaseExtension.swift savePersonFiredata")
                    let message = "\r\n" + NSLocalizedString("Data are now saved in Firebase.", comment: "DataBaseExtension.swift savePersonFiredata")
                    self.presentAlert(withTitle: title, message: message)
                } else {
                    let melding = error!.localizedDescription
                    self.presentAlert(withTitle: NSLocalizedString("Error", comment: "DataBaseExtension.swift savePersonFiredata"),
                                      message: melding)
                }
            })
        } else {
            let melding = "\r\n" + NSLocalizedString("Every field must be filled.",
                                                     comment: "DataBaseExtension.swift savePersonFiredata")
            
            self.presentAlert(withTitle: NSLocalizedString("Error",
                                                           comment: "DataBaseExtension.swift savePersonFiredata"),
                              message: melding)
        }
    }
    
    func formatPhone(phone: String) -> String {
        
        if phone.count == 8 {
            let index2 = phone.index(phone.startIndex, offsetBy: 2)
            let index3 = phone.index(phone.startIndex, offsetBy: 3)
            let index4 = phone.index(phone.startIndex, offsetBy: 4)
            let index5 = phone.index(phone.startIndex, offsetBy: 5)
            
            return String(phone[...index2]) + " " +
                   String(phone[index3...index4]) + " " +
                   String(phone[index5...])
        } else if phone.count == 10 {
            return phone
        }
        
        return ""
    }
    
}
