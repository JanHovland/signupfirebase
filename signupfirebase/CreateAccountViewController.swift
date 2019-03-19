//
//  CreateAccountViewController.swift
//  signupfirebase
//
//  Created by Jan  on 12/11/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import CoreData
import Firebase
import UIKit

class CreateAccountViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var activity: UIActivityIndicatorView!

    @IBOutlet var nameCreateAccountTextField: UITextField!
    @IBOutlet var eMailCreateAccountTextField: UITextField!
    @IBOutlet var passwordCreateAccountTextField: UITextField!
    
    var activeField: UITextField!

    // These 2 variables get their values via segue "gotoCreateAccount" in LogInViewController.swift
    var createEmail: String = ""
    var createPassord: String = ""

    @IBOutlet var inputImage: UIImageView! {
        didSet {
            inputImage.layer.cornerRadius = inputImage.bounds.width / 2
            inputImage.clipsToBounds = true
        }
    }
    
    var savePhoto: Bool = false

    // Called after the view has been loaded. For view controllers created in code, this is after -loadView. For view controllers unarchived from a nib, this is after the view is set.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Turn off keyboard when you press "Return"
        nameCreateAccountTextField.delegate = self
        eMailCreateAccountTextField.delegate = self
        passwordCreateAccountTextField.delegate = self
        
        // Insert the values from LogInViewController.swift
        eMailCreateAccountTextField.text = createEmail
        passwordCreateAccountTextField.text = createPassord

        // Initialize the activity
        activity.hidesWhenStopped = true
        activity.style = .gray
        view.addSubview(activity)
        
    }

    // Called when the view has been fully transitioned onto the screen. Default does nothing
    override func viewDidAppear(_ animated: Bool) {
        // Observe keyboard change
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeCreateAccount(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeCreateAccount(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeCreateAccount(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    // Called when the view is about to made visible. Default does nothing
    override func viewWillAppear(_ animated: Bool) {
    }
    
    @objc func keyboardWillChangeCreateAccount(notification: NSNotification) {
        
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }

        let distanceToBottom = view.frame.size.height - (activeField?.frame.origin.y)! - (activeField?.frame.size.height)!

        if keyboardRect.height > distanceToBottom {

            if notification.name == UIResponder.keyboardWillShowNotification ||
                notification.name == UIResponder.keyboardWillChangeFrameNotification {
                view.frame.origin.y = -(keyboardRect.height - distanceToBottom)
            } else {
                view.frame.origin.y = 0
            }

        }
    }
    
    // return NO to disallow editing.
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        return true
    }
    
    // called when 'return' key pressed. return NO to ignore.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        activeField?.resignFirstResponder()
        activeField = nil
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Dismiss the keyboard when the view is tapped on
        eMailCreateAccountTextField.resignFirstResponder()
        nameCreateAccountTextField.resignFirstResponder()
        passwordCreateAccountTextField.resignFirstResponder()
    }

    @IBAction func SaveAccount(_ sender: UIBarButtonItem) {
        var ok: Bool = false
        var ok1: Bool = false

        activity.startAnimating()
        
        // Dismiss the keyboard when the Save button is tapped on
        eMailCreateAccountTextField.resignFirstResponder()
        nameCreateAccountTextField.resignFirstResponder()
        passwordCreateAccountTextField.resignFirstResponder()
        
        DispatchQueue.main.async {

            if self.eMailCreateAccountTextField.text!.count > 0,
                self.nameCreateAccountTextField.text!.count > 0,
                self.passwordCreateAccountTextField.text!.count >= 6 {
                
                let region = NSLocale.current.regionCode?.lowercased()  // Returns the local region
                Auth.auth().languageCode = region!

                // Register the user with Firebase
                Auth.auth().createUser(withEmail: self.eMailCreateAccountTextField.text!,
                                       password: self.passwordCreateAccountTextField.text!) { _, error in

                    if error == nil {
                        // The user is stored in Firebase

                        let uid = Auth.auth().currentUser?.uid ?? ""
                        let name = self.nameCreateAccountTextField.text!

                        // Reset all posts where 'loggedin' == true
                        ok = self.resetLoggedIinCoreData()

                        if ok == true {
                            // Check if the user exists in CoreData
                            // Else, store the user in CoreData
                            ok = self.findCoreData(withEpost: self.eMailCreateAccountTextField.text!)

                            if ok == false {
                                
                                // Store the image og the new user
                                
                                self.savePhotoURL(image: self.inputImage.image!,
                                                  email: self.eMailCreateAccountTextField.text!,
                                                  completionHandler: { (url) in
                                
                                    ok1 = self.saveCoreData(withEpost: self.eMailCreateAccountTextField.text!,
                                                            withPassord: self.passwordCreateAccountTextField.text!,
                                                            withUid: uid,
                                                            withLoggedIn: true,
                                                            withName: name,
                                                            withPhotoURL: url)

                                    if ok1 == false {
                                        let melding = NSLocalizedString("Unable to store data in CoreData.",
                                                                        comment: "CreateAccountViewVontroller.swift CheckLogin verdi")
                                        
                                        self.presentAlert(withTitle: NSLocalizedString("Error",
                                                                                       comment: "CreateAccountViewVontroller.swift SaveAccount "),
                                                          message: melding)
                                        
                                    } else {
                                        let region = NSLocale.current.regionCode?.lowercased()  // Returns the local region
                                        Auth.auth().languageCode = region!
                                        
                                        // Store the name of the user in Firebase
                                        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                                        changeRequest?.displayName = self.nameCreateAccountTextField.text!
                                        // changeRequest?.photoURL = URL(string: value2.photoURL)
                                        
                                        changeRequest?.commitChanges { error in
                                            if error == nil {
                                                self.dismiss(animated: false, completion: nil)
                                            } else {
                                                let melding = error!.localizedDescription
                                                self.presentAlert(withTitle: NSLocalizedString("Error", comment: "CreateAccountViewVontroller.swift SaveAccount"),
                                                                  message: melding)
                                            }
                                            self.activity.stopAnimating()
                                        }
                                    }
                                                    
                                })
                                
                            } else {
                                // Update CoreData with 'loggedin' == true
                                ok = self.updateCoreData(withEpost: self.eMailCreateAccountTextField.text!, withLoggedIn: true)

                                if ok == false {
                                    let melding = NSLocalizedString("Unable to store data in CoreData.",
                                                                    comment: "CreateAccountViewVontroller.swift CheckLogin verdi")
                                    
                                    self.presentAlert(withTitle: NSLocalizedString("Error",
                                                                                   comment: "CreateAccountViewVontroller.swift SaveAccount "),
                                                      message: melding)
                                    
                                } else {
                                    let region = NSLocale.current.regionCode?.lowercased()  // Returns the local region
                                    Auth.auth().languageCode = region!

                                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                                    changeRequest?.displayName = self.nameCreateAccountTextField.text!

                                    changeRequest?.commitChanges { error in
                                        if error == nil {
                                            self.dismiss(animated: false, completion: nil)
                                        } else {
                                            let melding = error!.localizedDescription
                                            self.presentAlert(withTitle: NSLocalizedString("Error", comment: "CreateAccountViewVontroller.swift SaveAccount"),
                                                         message: melding)
                                        }
                                    }
                                    
                                    // Only save photo if a photo has been picked
                                    if self.savePhoto == true {
                                        
                                        self.savePhotoURL(image: self.inputImage.image!,
                                                          email: self.eMailCreateAccountTextField.text!,
                                                          completionHandler: { (url) in
                                                            
                                            //  0 = uid  1 = eMail 2 = name  3 = passWord 4 = photoURL
                                            let value = self.getCoreData()
                                            let OK = self.saveCoreData(withEpost: value.eMail,
                                                                       withPassord: value.passWord,
                                                                       withUid: value.uid,
                                                                       withLoggedIn: true,
                                                                       withName: value.name,
                                                                       withPhotoURL: url)
                                            
                                            if OK == false {
                                                let melding = NSLocalizedString("Unable to store data in FireBase.",
                                                                                comment: "LoginViewVontroller.swift CheckLogin")
                                                self.presentAlert(withTitle: NSLocalizedString("Error.",
                                                                                               comment: "LoginViewVontroller.swift CheckLogin"),
                                                                  message: melding)
                                                
                                            } else {
                                                
                                                let value1 = self.getCoreData()
                                                
                                                if let image = CacheManager.shared.getFromCache(key: value.photoURL) as? UIImage, self.savePhoto == false {
                                                    self.inputImage.image = image
                                                } else {
                                                    self.savePhoto = false
                                                    if let url = URL(string: value1.photoURL) {
                                                        
                                                        let findCellImage = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                                                            guard let imageData = data else {
                                                                self.activity.stopAnimating()
                                                                return
                                                            }
                                                            OperationQueue.main.addOperation {
                                                                guard let image = UIImage(data: imageData) else {
                                                                    self.activity.stopAnimating()
                                                                    return
                                                                }
                                                                
                                                                self.inputImage.image = image
                                                                
                                                                // Add the downloaded image to cache
                                                                CacheManager.shared.cache(object: image, key: value.photoURL)
                                                            }
                                                        })
                                                        
                                                        findCellImage.resume()
                                                    }
                                                }
                                                
                                            }
                                            
                                        })
                                        
                                    } else {
                                        let value = self.getCoreData()
                                        
                                        if let image = CacheManager.shared.getFromCache(key: value.photoURL) as? UIImage, self.savePhoto == false {
                                            self.inputImage.image = image
                                        } else {
                                            self.savePhoto = false
                                            if let url = URL(string: value.photoURL) {
                                                
                                                let findCellImage = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                                                    guard let imageData = data else {
                                                        self.activity.stopAnimating()
                                                        return
                                                    }
                                                    OperationQueue.main.addOperation {
                                                        guard let image = UIImage(data: imageData) else {
                                                            self.activity.stopAnimating()
                                                            return
                                                        }
                                                        
                                                        self.inputImage.image = image
                                                        
                                                        // Add the downloaded image to cache
                                                        CacheManager.shared.cache(object: image, key: value.photoURL)
                                                    }
                                                })
                                                
                                                findCellImage.resume()
                                            }
                                        }
                                        
                                    }
                                 }
                                
                            }

                        } else {
                            let melding = NSLocalizedString("Unable to store data in CoreData.",
                                                            comment: "CreateAccountViewVontroller.swift CheckLogin verdi")
                            
                            self.presentAlert(withTitle: NSLocalizedString("Error",
                                                                           comment: "CreateAccountViewVontroller.swift SaveAccount "),
                                              message: melding)
                            
                        }

                    } else {
                        self.presentAlert(withTitle: NSLocalizedString("Error", comment: "CreateAccountViewVontroller.swift SaveAccount"),
                                          message: error!.localizedDescription as String)
                    }
                                        
                    self.activity.stopAnimating()
                    
                }

            } else {
                if self.passwordCreateAccountTextField.text!.count < 6 {
                    let melding1 = NSLocalizedString("Every field must have a value.", comment: "CreateAccountViewVontroller.swift SaveAccount ")
                    let melding2 = NSLocalizedString("The password must contain minimum 6 characters", comment: "CreateAccountViewVontroller.swift SaveAccount ")
                    let melding = melding1 + "\r\n" + melding2
                    
                    self.presentAlert(withTitle: NSLocalizedString("Error", comment: "CreateAccountViewVontroller.swift SaveAccount"),
                                 message: melding)
                } else {
                    let melding = NSLocalizedString("Every field must have a value", comment: "LoginViewVontroller.swift SaveAccount")
                    self.presentAlert(withTitle: NSLocalizedString("Error", comment: "CreateAccountViewVontroller.swift SaveAccount"),
                                 message: melding)
                }
            }
            
            
        }
 
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Remove observers
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @IBAction func selectPersonPhoto(_ sender: UIButton) {
        
        let melding = NSLocalizedString("Choose your photo source", comment: "LoginViewVontroller.swift selectPersonPhoto")
        
        let photoSourceRequestController = UIAlertController(title: "", message: melding, preferredStyle: .actionSheet)
        
        let title = NSLocalizedString("Camera", comment: "LoginViewVontroller.swift selectPersonPhoto")
        
        let cameraAction = UIAlertAction(title: title, style: .default, handler: { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = true
                imagePicker.sourceType = .camera
                imagePicker.delegate = self
                self.present(imagePicker, animated: true, completion: nil)
            }
        })
        
        let title1 = NSLocalizedString("Photo library", comment: "LoginViewVontroller.swift selectPersonPhoto")
        
        let photoLibraryAction = UIAlertAction(title: title1, style: .default, handler: { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = true
                imagePicker.sourceType = .photoLibrary
                imagePicker.delegate = self
                self.present(imagePicker, animated: true, completion: nil)
            }
        })
        
        let title2 = NSLocalizedString("Cancel", comment: "LoginViewVontroller.swift selectPersonPhoto")
        
        photoSourceRequestController.addAction(cameraAction)
        photoSourceRequestController.addAction(photoLibraryAction)
        photoSourceRequestController.addAction(UIAlertAction(title: title2, style: .default, handler: nil))
        
        present(photoSourceRequestController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Find the person's new photo
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            inputImage.image = image
            inputImage.contentMode = .scaleAspectFill
            inputImage.clipsToBounds = true
            
            savePhoto = true
            
        }
        
        dismiss(animated: true, completion: nil)
    }

    
}
