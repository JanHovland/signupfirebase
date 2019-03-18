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

// Stuck in us Keyboard: 
// Go to Product > Scheme > Edit Scheme...

class LogInViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var activity: UIActivityIndicatorView!
    @IBOutlet var eMailLoginTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet weak var loginStatus: UITextField!
    
    @IBOutlet weak var inputImage: UIImageView! {
        didSet {
            inputImage.layer.cornerRadius = inputImage.bounds.width / 2
            inputImage.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var photoButton: UIButton!
    
    var status: Bool = true
    var activeField: UITextField!
    
    var savePhoto: Bool = false
    
    // Called after the view has been loaded. For view controllers created in code, this is after -loadView. For view controllers unarchived from a nib, this is after the view is set.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide the photoButton
        photoButton.isHidden = true
        
        // Hide the tabBar
        self.tabBarController?.tabBar.isHidden = true
        
        // Set "SHOWPASSWORD" to false
        UserDefaults.standard.set(false, forKey: "SHOWPASSWORD")
        
        // Initialize the UIActivityIndicatorView
        activity.hidesWhenStopped = true
        activity.style = .gray
        view.addSubview(activity)

        // Show login info
        loginStatus.text = showUserInfo(startUp: true)
        
        // Turn off keyboard when you press "Return"
        eMailLoginTextField.delegate = self
        passwordTextField.delegate = self
        
        // Turns off the tabBarController?.tabBar if the text in the 2 fields is changed
        eMailLoginTextField.addTarget(self,
                                      action: #selector(textFieldEditingChanged),
                                      for: UIControl.Event.editingChanged)
        
        passwordTextField.addTarget(self,
                                    action: #selector(textFieldEditingChanged),
                                    for: UIControl.Event.editingChanged)
    }
    
    // Called when the view has been fully transitioned onto the screen. Default does nothing
    override func viewDidAppear(_ animated: Bool) {
     
        // Hide the BackButton when returning from change/reset password
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        // Observe keyboard change
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeLogin(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeLogin(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeLogin(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        if (UserDefaults.standard.bool(forKey: "SHOWPASSWORD")) == true {
            self.passwordTextField.isSecureTextEntry = false
        } else {
            self.passwordTextField.isSecureTextEntry = true
        }
        
        // Turn off keyboard when you press "Return"
        eMailLoginTextField.delegate = self
        passwordTextField.delegate = self
        
        let value = getCoreData()
        
        eMailLoginTextField.text! = value.eMail
        passwordTextField.text! = value.passWord
        
        // Show the photo for the current user
        if let image = CacheManager.shared.getFromCache(key: value.photoURL) as? UIImage {
            inputImage.image = image
        } else {
            if let url = URL(string: value.photoURL) {
                
                let findCellImage = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                    guard let imageData = data else {
                        return
                    }
                    OperationQueue.main.addOperation {
                        guard let image = UIImage(data: imageData) else {
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
    
    @objc func textFieldEditingChanged(_ sender: UITextField) {
        // Hide the tabBar
        if self.tabBarController?.tabBar.isHidden == false {
           self.tabBarController?.tabBar.isHidden = true
           // self.loginStatus.text = self.showUserInfo(startUp: true)
        }
    }
    
    @objc func keyboardWillChangeLogin(notification: NSNotification) {
        
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
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        activeField?.resignFirstResponder()
        activeField = nil
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Dismiss the keyboard when the view is tapped on
        eMailLoginTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }

    @IBAction func LogIn(_ sender: UIBarButtonItem) {
        CheckLogin()
    }
    
    func CheckLogin() {
        
        var ok: Bool = false
    
        // Dismiss the keyboard when the Next button is tapped on
        eMailLoginTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()

        if eMailLoginTextField.text!.count > 0,
            passwordTextField.text!.count >= 6 {
            activity.startAnimating()
            
            let region = NSLocale.current.regionCode  // Returns the local region
            Auth.auth().languageCode = region
            
            // Check if eMail and password exist in Firebase
            Auth.auth().signIn(withEmail: eMailLoginTextField.text!, password: passwordTextField.text!) { _, error in

                if error == nil {
                    // let uid = Auth.auth().currentUser?.uid ?? ""
                    let navn = Auth.auth().currentUser?.displayName ?? ""

                    // Reset all posts where 'loggedin' == true
                    ok = self.resetLoggedIinCoreData()

                    if ok == true {
                        // Check if the user exists in CoreData
                        // If not, store the user in CoreData
                        ok = self.findCoreData(withEpost: self.eMailLoginTextField.text!)

                        if ok == false {
                            
                        } else {
                            
                            // Find the password from CoreData, if it is different from Firedata, Update CoreData
                            if self.findPasswordCoreData(withEpost: self.eMailLoginTextField.text!) != self.passwordTextField.text! {
                                // Store the new password in CoreData
                                ok = self.updatePasswordCoreData(withEpost: self.eMailLoginTextField.text!,
                                                                 withPassWord: self.passwordTextField.text!)

                                if ok == false {
                                    let melding = NSLocalizedString("Unable to update the password in FireBase.",
                                                                    comment: "LoginViewVontroller.swift CheckLogin")
                                    
                                    self.presentAlert(withTitle: NSLocalizedString("Error.",
                                                                                   comment: "LoginViewVontroller.swift CheckLogin updatepassword"),
                                                     message: melding)
                                }
                            }

                            // Update CoreData with 'loggedin' == true
                            ok = self.updateCoreData(withEpost: self.eMailLoginTextField.text!, withLoggedIn: true)

                            if ok == false {
                                let melding = NSLocalizedString("Unable to update 'loggedin' in FireBase.",
                                                                comment: "LoginViewVontroller.swift CheckLogin 'loggedin'")
                                
                                self.presentAlert(withTitle: NSLocalizedString("Error.",
                                                                                comment: "LoginViewVontroller.swift CheckLogin error"),
                                                  message: melding)
                            } else {
                                // Blank the login message 
                                self.loginStatus.text = ""
                                
                                // Show the tabBar
                                self.tabBarController?.tabBar.isHidden = false
                                self.photoButton.isHidden = false
                                
                                // Only save photo if a photo has been picked
                                if self.savePhoto == true {
                                    
                                    self.savePhotoURL(image: self.inputImage.image!,
                                                      email: self.eMailLoginTextField.text!,
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
                                                            return
                                                        }
                                                        OperationQueue.main.addOperation {
                                                            guard let image = UIImage(data: imageData) else {
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
                                                    return
                                                }
                                                OperationQueue.main.addOperation {
                                                    guard let image = UIImage(data: imageData) else {
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

                       // self.loginStatus.text = self.showUserInfo(startUp: false)
                        
                    } else {
                        let melding = NSLocalizedString("Unable to update CoreData.",
                                                        comment: "LoginViewVontroller.swift CheckLogin 'update'")
                        
                        self.presentAlert(withTitle: NSLocalizedString("Error",
                                                                       comment: "LoginViewVontroller.swift CheckLogin error"),
                                          message: melding)
                        
                    }

                } else {
                    
                    let withTitle =   NSLocalizedString("Error", comment: "LoginViewVontroller.swift CheckLogin 'error'")
                    let firstTitle =  NSLocalizedString("Add a new user", comment: "LoginViewVontroller.swift presentAlertCreateAccount")
                    let secondTitle = NSLocalizedString("Try one more time", comment: "LoginViewVontroller.swift presentAlertCreateAccount")
                    
                    // The first will have handler: { _ in CreateAccount() }) og vil åpne CreateAccount
                    // The second handler will have handler: nil og vil så lukke presentAlertCreateAccount
                    
                    self.presentAlertCreateAccount(withTitle: withTitle,
                                                   message: error!.localizedDescription as String,
                                                   firstTitle: firstTitle,
                                                   secondTitle: secondTitle)
                    
                }
            }

            activity.stopAnimating()

        } else {
            let melding1 = NSLocalizedString("eMail must have a value.",
                                             comment: "LoginViewVontroller.swift CheckLogin verdi")
            
            let melding2 = NSLocalizedString("The password must contain minimum 6 characters",
                                             comment: "LoginViewVontroller.swift CheckLogin verdi")
            
            let melding = melding1 + "\r\n" + melding2
            
            self.presentAlert(withTitle: NSLocalizedString("Error",
                                                           comment: "LoginViewVontroller.swift CheckLogin 'error'"),
                              message: melding)
            
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 'prepare' will run after every segue.
        // Here it shall only run after : performSegue(withIdentifier: "gotoCreateAccount", sender: self)

        if segue.identifier! == "gotoCreateAccount" {
            let vc = segue.destination as! CreateAccountViewController

            // createEmail og createPassord er variabler som er definert i CreateAccountViewController.swift
            vc.createEmail = eMailLoginTextField.text!
            vc.createPassord = passwordTextField.text!
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
