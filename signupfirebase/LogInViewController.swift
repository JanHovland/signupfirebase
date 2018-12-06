//
//  LogInViewController.swift
//  signupfirebase
//
//  Created by Jan  on 11/11/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import CoreData
import Firebase
import UIKit

class LogInViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var activity: UIActivityIndicatorView!

    @IBOutlet var eMailLoginTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setter "SHOWPASSWORD" til false
        UserDefaults.standard.set(false, forKey: "SHOWPASSWORD")
        
        // For å kunne avslutte visning av tastatur når en trykker "Ferdig" på tastauuret
        eMailLoginTextField.delegate = self
        passwordTextField.delegate = self

        // Initierer UIActivityIndicatorView
        activity.hidesWhenStopped = true
        activity.style = .gray
        view.addSubview(activity)

        // Start activity
        activity.startAnimating()

        // Henter sist brukte eMail og Password der CoreData sin "loggedIn" = true
        // Hvis det ikke finnes noen post med loggedin = true, blankes eMailLoginTextField og passwordTextField
        let value = getCoreData()
        eMailLoginTextField.text = value.0
        passwordTextField.text = value.1

        activity.stopAnimating()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Dismiss the keyboard when the view is tapped on
        eMailLoginTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }

    @IBAction func NextButtonTapped(_ sender: UIBarButtonItem) {
        
        var ok: Bool = false
        var ok1: Bool = false
        var uid: String = ""
        var navn: String = ""

        // Dismiss the keyboard when the Next button is tapped on
        eMailLoginTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()

        if eMailLoginTextField.text!.count > 0,
            passwordTextField.text!.count >= 6 {
            activity.startAnimating()

            // Sjekk om eposten og passordet er registrert som bruker i Firebase
            Auth.auth().signIn(withEmail: eMailLoginTextField.text!, password: passwordTextField.text!) { _, error in

                if error == nil {
                    uid = Auth.auth().currentUser?.uid ?? ""
                    print("uid fra NextButtonTapped: \(uid)")

                    navn = Auth.auth().currentUser?.displayName ?? ""

                    // Resetter alle postene som hvor loggedin == true
                    ok = self.resetLoggedIinCoreData()

                    if ok == true {
                        // Sjekk om brukeren finnes i CoreData
                        // Hvis ikke, lagre brukeren i CoreData
                        ok = self.findCoreData(withEpost: self.eMailLoginTextField.text!)

                        if ok == false {
                            ok1 = self.saveCoreData(withEpost: self.eMailLoginTextField.text!,
                                                    withPassord: self.passwordTextField.text!,
                                                    withUid: uid,
                                                    withLoggedIn: true,
                                                    withName: navn)

                            if ok1 == false {
                                let melding = "Kan ikke lagre en ny post i CoreData."
                                self.presentAlert(withTitle: "Feil", message: melding)
                            }

                        } else {
                            
                            // Finn passordet fra CoreData, dersom dette er forskjellig fra Firedata, oppdater CoreData
                            if self.findPasswordCoreData(withEpost: self.eMailLoginTextField.text!) != self.passwordTextField.text! {
                            
                                // Legger det nye passordet inn i CoreData
                                ok = self.updatePasswordCoreData(withEpost: self.eMailLoginTextField.text!,
                                                                 withPassWord: self.passwordTextField.text!)
                                
                                if ok == false {
                                    let melding = "Kan ikke oppdatere passordet i CoreData."
                                    self.presentAlert(withTitle: "Feil", message: melding)
                                }

                            }
                            
                            // oppdaterer CoreData med loggedin == true
                            ok = self.updateCoreData(withEpost: self.eMailLoginTextField.text!, withLoggedIn: true)

                            if ok == false {
                                let melding = "Kan ikke oppdatere 'loggedin' i CoreData."
                                self.presentAlert(withTitle: "Feil", message: melding)
                            }
                        }

                        // Går til Settings bildet
                        self.performSegue(withIdentifier: "gotoSettingsFromLogin", sender: self)

                    } else {
                        let melding = "Kan ikke oppdatere en post(er) i CoreData."
                        self.presentAlert(withTitle: "Feil", message: melding)
                    }

                } else {
                    self.presentAlertOption(withTitle: "Feil", message: error!.localizedDescription as Any)
                }
            }

            activity.stopAnimating()

        } else {
            let melding = "eMail må ha en verdi.\nPassword må være minst 6 tegn langt"
            presentAlert(withTitle: "Feil", message: melding)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        eMailLoginTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // prepare kjøres etter hvilken som helst segue.
        // Skal bare kjøres etter: performSegue(withIdentifier: "gotoCreateAccount", sender: self)

        print(segue.identifier as Any)

        if segue.identifier! == "gotoCreateAccount" {
            let vc = segue.destination as! CreateAccountViewController

            // createEmail og createPassord er variabler som er definert i CreateAccountViewController.swift
            vc.createEmail = eMailLoginTextField.text!
            vc.createPassord = passwordTextField.text!
        }
    }
}

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

    func getCoreData() -> (String, String) {
        var ePost: String = ""
        var passWord: String = ""

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
                }
            }

        } catch {
            print(error.localizedDescription)
        }

        return (ePost, passWord)
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
}
