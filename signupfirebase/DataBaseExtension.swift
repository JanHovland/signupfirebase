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
                      withName: String,
                      withPhotoURL: String) -> Bool {
        
        var ok: Bool = false
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "User", in: context)
        
        let newEntity = NSManagedObject(entity: entity!, insertInto: context)
        
        newEntity.setValue(withEpost, forKey: "email")
        newEntity.setValue(withPassord, forKey: "password")
        newEntity.setValue(withUid, forKey: "uid")
        newEntity.setValue(withLoggedIn, forKey: "loggedin")
        newEntity.setValue(withName, forKey: "name")
        newEntity.setValue(withPhotoURL, forKey: "photoURL")
        
        
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
    
    func getCoreData() -> (uid: String,
        eMail: String,
        name: String,
        passWord: String,
        photoURL: String) {
            
            var uid: String = ""
            var ePost: String = ""
            var name: String = ""
            var passWord: String = ""
            var photoURL = ""
            
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
                        
                        if data.value(forKey: "photoURL") != nil {
                            photoURL = data.value(forKey: "photoURL") as! String
                        }
                    }
                }
                
            } catch {
                let melding = error.localizedDescription
                self.presentAlert(withTitle: NSLocalizedString("Error", comment: "DataBaseExtension.swift getCoreData"),
                                  message: melding)
            }
            
            return (uid, ePost, name, passWord, photoURL)
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
        //  0 = uid  1 = eMail  2 = name  3 = passWord)
        let value = getCoreData()
        
        let email = value.eMail
        let name = value.name
        
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
    
    func formatPhone(phone: String) -> String {
        
        if phone.count > 0 {
            if phone.count == 8 {
                
                // Check that there are no spaces
                if (isNumeric(string: phone)) {
                    
                    let index2 = phone.index(phone.startIndex, offsetBy: 2)
                    let index3 = phone.index(phone.startIndex, offsetBy: 3)
                    let index4 = phone.index(phone.startIndex, offsetBy: 4)
                    let index5 = phone.index(phone.startIndex, offsetBy: 5)
                    
                    return "+47 " +
                        String(phone[...index2]) + " " +
                        String(phone[index3...index4]) + " " +
                        String(phone[index5...])
                } else {
                    showAlert()
                }
                
            } else if phone.count == 10 {
                
                // Check the formatting with 2 spaces
                
                let idx2 = phone.index(phone.startIndex, offsetBy: 2)
                let idx3 = phone.index(phone.startIndex, offsetBy: 3)
                let idx4 = phone.index(phone.startIndex, offsetBy: 4)
                let idx5 = phone.index(phone.startIndex, offsetBy: 5)
                let idx6 = phone.index(phone.startIndex, offsetBy: 6)
                let idx7 = phone.index(phone.startIndex, offsetBy: 7)
                
                let t1 = String(phone[...idx2])
                
                if isNumeric(string: t1) == true {
                    
                    let t2 = String(phone[idx3...idx3])
                    
                    if t2 == " " {
                        let t3 = String(phone[idx4...idx5])
                        
                        if isNumeric(string: t3) == true {
                            
                            let t4 = String(phone[idx6...idx6])
                            
                            if t4 == " " {
                                let t5 = String(phone[idx7...])
                                
                                if isNumeric(string: t5) == true {
                                    
                                    let phone = "+47 " + phone
                                    return phone
                                    
                                } else {
                                    showAlert()
                                }
                            } else {
                                showAlert()
                            }
                            
                        } else {
                            showAlert()
                        }
                    } else {
                        showAlert()
                    }
                } else {
                    showAlert()
                }
                
            } else if phone.count == 14 {
                // +47 123 45 678
            } else {
                showAlert()
            }
            
        }
        
        return phone
    }
    
    // Returns true if the string is numeric
    func isNumeric(string: String) -> Bool {
        return Double(string) != nil
    }
    
    // Show the alert
    
    func showAlert() {
        let melding = "\r\n" + NSLocalizedString("The phonenumber must include 8 digits.\nThe country code prefix will automaticall be added.\n\nFormat: +47 123 45 678",
                                                 comment: "DataBaseExtension.swift formatPhone")
        self.presentAlert(withTitle: NSLocalizedString("Invalid phone number",
                                                       comment: "DataBaseExtension.swift formatPhone"),
                          message: melding)
    }
    
    func savePostalCodesFiredata(postnummer: String,
                                 poststed: String,
                                 kommunenummer: String,
                                 kommune: String)  {
        
        if  postnummer.count > 0,
            poststed.count > 0,
            kommunenummer.count > 0,
            kommune.count > 0 {
            
            let dataBase = Database.database().reference().child("postnr").childByAutoId()
            
            let postObject = [
                "postnummer": postnummer,
                "poststed": poststed,
                "kommunenummer": kommunenummer,
                "kommune": kommune
                ] as [String: Any]
            
            dataBase.setValue(postObject, withCompletionBlock: { error, _ in
                if error == nil {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    let melding = error!.localizedDescription
                    self.presentAlert(withTitle: NSLocalizedString("Error", comment: "DataBaseExtension.swift savePostalCodesFiredata"),
                                      message: melding)
                }
            })
        } else {
            let melding = "\r\n" + NSLocalizedString("Every field must be filled in.",
                                                     comment: "DataBaseExtension.swift savePostalCodesFiredata")
            
            self.presentAlert(withTitle: NSLocalizedString("Error",
                                                           comment: "DataBaseExtension.swift savePostalCodesFiredata"),
                              message: melding)
        }
    }
    
    
    func savePhotoURL(image: UIImage,
                      email: String,
                      completionHandler: @escaping (String) -> Void) {
        
        let PHOTO_STORAGE_REF: StorageReference = Storage.storage().reference().child("photos")
        let imageStorageRef = PHOTO_STORAGE_REF.child("\(email).png")
        
        print(imageStorageRef as Any)
        
        // Resize the image
        let scaledImage = image.scale(newWidth: 50.0)
        
        guard let imageData = scaledImage.jpegData(compressionQuality: 0.5) else {
            return
        }
        
        // Create the file metadata
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
        // Prepare the upload task
        let uploadTask = imageStorageRef.putData(imageData, metadata: metadata)
        
        // Prepare the upload status
        uploadTask.observe(.success) { (snapshot) in
            
            // Add a reference in the database
            snapshot.reference.downloadURL(completion: { (url, error) in
                guard let url = url else {
                    return
                }
                
                print(url)
                
                completionHandler(url.absoluteString)
            })
        }
    }
    
}
