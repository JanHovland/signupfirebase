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
    
    // Called after the view has been loaded. For view controllers created in code, this is after -loadView. For view controllers unarchived from a nib, this is after the view is set.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide the users's photo
        inputImage.isHidden = true
        
        // Hide the photoButton
        photoButton.isHidden = true
        
        // Hide the tabBar
        self.tabBarController?.tabBar.isHidden = true
        
        // Set "SHOWPASSWORD" to false
        UserDefaults.standard.set(false, forKey: "SHOWPASSWORD")
        
        // Initialize the UIActivityIndicatorView
        activity.hidesWhenStopped = true
        activity.style = .gray
        activity.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
    
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
        
        loginStatus.text = self.showUserInfo(startUp: true)
        
        // Finds data from the last user signed in
        let value = getCoreData()
        
        if value.eMail.count > 0, value.passWord.count > 0 {

            eMailLoginTextField.text = value.eMail
            passwordTextField.text = value.passWord
        
        }
        
    }
    
    // // Called when the view is about to made visible. Default does nothing
    override func viewWillAppear(_ animated: Bool) {
        
        // Hide the photo
        inputImage.isHidden = true
        
        // Show info to log in
        loginStatus.text = self.showUserInfo(startUp: true)

        // Hide the photoButton
        photoButton.isHidden = true
        
        // Hide the tabBar
        tabBarController?.tabBar.isHidden = true
        
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

    }
    
    @objc func textFieldEditingChanged(_ sender: UITextField) {
        // Hide the tabBar
        if self.tabBarController?.tabBar.isHidden == false {
           self.tabBarController?.tabBar.isHidden = true
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
        
        // Dismiss the keyboard when the Next button is tapped on
        eMailLoginTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()

        // Check email and passw0rd
        if self.eMailLoginTextField.text!.count > 0,
            self.passwordTextField.text!.count >= 6 {

            self.activity.startAnimating()
            
            // Check if eMail and password exist in Firebase
            Auth.auth().signIn(withEmail: self.eMailLoginTextField.text!, password: self.passwordTextField.text!) { (_, error) in

                if error == nil {
                    
                    print(Auth.auth().currentUser?.photoURL as Any)
                    
                    // Check if the current user has a value in photoURL
                    // If not, use the default photo
                    if Auth.auth().currentUser?.photoURL == nil {
                        
                        self.inputImage.image = UIImage(named: "new-person.png")

                        self.inputImage.contentMode = .scaleAspectFill
                        self.inputImage.clipsToBounds = true
                        
                        self.savePhotoUrlFirestore(image: self.inputImage.image!,
                                                   email: self.eMailLoginTextField.text!,
                                                   completionHandler: { (url) in
                                                    
                            let uid = Auth.auth().currentUser?.uid ?? ""
                            let name = Auth.auth().currentUser?.displayName ?? ""
                            
                            let _ = self.deleteAllCoreData()
                            
                            let ok1 = self.saveCoreData(withEpost: self.eMailLoginTextField.text!,
                                                        withPassord: self.passwordTextField.text!,
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
                                
                                // Store the name of the user in Firebase
                                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                                changeRequest?.photoURL = URL(string: url)
                                
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
                        
                        // Show the photo of the user
                        let findCellImage = URLSession.shared.dataTask(with: (Auth.auth().currentUser?.photoURL)!, completionHandler: { (data, response, error) in
                            guard let imageData = data else {
                                return
                            }
                            OperationQueue.main.addOperation {
                                guard let image = UIImage(data: imageData) else {
                                    return
                                }

                                self.inputImage.image = image

                            }
                        })

                        findCellImage.resume()
                
                        // Enable showing the photo
                        self.inputImage.isHidden = false
                        
                    }
                    
                    // Show the photoButton
                    self.photoButton.isHidden = false
                    
                    // Show the tabBar
                    self.tabBarController?.tabBar.isHidden = false

                    // Blank the login message
                    self.loginStatus.text = ""
                    
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
            
            self.activity.stopAnimating()
            
        } else {
            
            // Give an alert when email and/or password is missing/false length
            
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
        // The 'prepare' function will run after every segue.
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
    
    // Find a new photo from the Camera or the photoLibrary
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
            
            self.savePhotoUrlFirestore(image: self.inputImage.image!,
                                       email: self.eMailLoginTextField.text!,
                                       completionHandler: { (url) in
                                        
                let uid = Auth.auth().currentUser?.uid ?? ""
                let name = Auth.auth().currentUser?.displayName ?? ""
                                        
                let _ = self.deleteAllCoreData()
                                        
                let ok1 = self.saveCoreData(withEpost: self.eMailLoginTextField.text!,
                                        withPassord: self.passwordTextField.text!,
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
                    
                    // Store the user's photoURL in Firebase
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.photoURL = URL(string: url)
                    
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
            
        }
        
        dismiss(animated: true, completion: nil)
    }


}
