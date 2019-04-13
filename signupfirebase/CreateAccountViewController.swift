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
import Foundation


import Foundation
import FirebaseStorage


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

        activity.startAnimating()
        
        // Dismiss the keyboard when the Save button is tapped on
        eMailCreateAccountTextField.resignFirstResponder()
        nameCreateAccountTextField.resignFirstResponder()
        passwordCreateAccountTextField.resignFirstResponder()
        
        if self.eMailCreateAccountTextField.text!.count > 0,
            self.nameCreateAccountTextField.text!.count > 0,
            self.passwordCreateAccountTextField.text!.count >= 6 {
            
            // Register the user with Firebase
            Auth.auth().createUser(withEmail: self.eMailCreateAccountTextField.text!,
                                   password: self.passwordCreateAccountTextField.text!) { _, error in

                if error != nil {
                    self.activity.stopAnimating()
                    let title = NSLocalizedString("Create account.", comment: "CreateAccountViewController.swift SaveAccount")
                    self.presentAlert(withTitle: title,
                                      message: error!.localizedDescription as String)
                } else {
                    
                    self.inputImage.image = UIImage(named: "new-person.png")
                    
                    self.inputImage.contentMode = .scaleAspectFill
                    self.inputImage.clipsToBounds = true
                    
                    self.savePhotoUrlFirestore(image: self.inputImage.image!,
                                               email: self.eMailCreateAccountTextField.text!,
                                               completionHandler: { (url) in
                                                
                        let uid = Auth.auth().currentUser?.uid ?? ""
                        let name = Auth.auth().currentUser?.displayName ?? ""
                        
                        let _ = self.deleteAllCoreData()
                        
                        let ok1 = self.saveCoreData(withEpost: self.eMailCreateAccountTextField.text!,
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

            }
            
        } else {
            if self.passwordCreateAccountTextField.text!.count < 6 {
                let melding1 = NSLocalizedString("Every field must have a value.", comment: "CreateAccountViewVontroller.swift SaveAccount ")
                let melding2 = NSLocalizedString("The password must contain minimum 6 characters", comment: "CreateAccountViewVontroller.swift SaveAccount ")
                let melding = melding1 + "\r\n" + melding2
                
                self.presentAlert(withTitle: NSLocalizedString("Error", comment: "CreateAccountViewVontroller.swift SaveAccount"),
                             message: melding)
            } else {
                let melding = NSLocalizedString("Every field must have a value", comment: "CreateAccountViewController.swift SaveAccount")
                self.presentAlert(withTitle: NSLocalizedString("Error", comment: "CreateAccountViewVontroller.swift SaveAccount"),
                             message: melding)
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
        
        let melding = NSLocalizedString("Choose your photo source", comment: "CreateAccountViewController.swift selectPersonPhoto")
        
        let photoSourceRequestController = UIAlertController(title: "", message: melding, preferredStyle: .actionSheet)
        
        let title = NSLocalizedString("Camera", comment: "CreateAccountViewController.swift selectPersonPhoto")
        
        let cameraAction = UIAlertAction(title: title, style: .default, handler: { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = true
                imagePicker.sourceType = .camera
                imagePicker.delegate = self
                self.present(imagePicker, animated: true, completion: nil)
            }
        })
        
        let title1 = NSLocalizedString("Photo library", comment: "CreateAccountViewController.swift selectPersonPhoto")
        
        let photoLibraryAction = UIAlertAction(title: title1, style: .default, handler: { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = true
                imagePicker.sourceType = .photoLibrary
                imagePicker.delegate = self
                self.present(imagePicker, animated: true, completion: nil)
            }
        })
        
        let title2 = NSLocalizedString("Cancel", comment: "CreateAccountViewController.swift selectPersonPhoto")
        
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

extension AuthErrorCode {
    var description: String? {
        switch self {
        case .accountExistsWithDifferentCredential:
            return NSLocalizedString("Account exists with different credential", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .appNotAuthorized:
            return NSLocalizedString("App not authorized", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .appNotVerified:
            return NSLocalizedString("App not verified", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .appVerificationUserInteractionFailure:
            return NSLocalizedString("App verification user interaction failure", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .captchaCheckFailed:
            return NSLocalizedString("Captcha check failed", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .credentialAlreadyInUse:
            return NSLocalizedString("Credential already in use", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .customTokenMismatch:
            return NSLocalizedString("Custom token mismatch", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .emailAlreadyInUse:
            return NSLocalizedString("The email address is already in use by another account.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .expiredActionCode:
            return NSLocalizedString("Expired action code", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .internalError:
            return NSLocalizedString("Internal error", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .invalidActionCode:
            return NSLocalizedString("Invalid action code", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .invalidAPIKey:
            return NSLocalizedString("Invalid API key", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .invalidAppCredential:
            return NSLocalizedString("Invalid app credential", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .invalidClientID:
            return NSLocalizedString("Invalid client ID", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .invalidContinueURI:
            return NSLocalizedString("Invalid continue URI", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .invalidCredential:
            return NSLocalizedString("Invalid credential", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .invalidCustomToken:
            return NSLocalizedString("Invalid personalized token", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .invalidEmail:
            return NSLocalizedString("E-mail not valid", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .invalidMessagePayload:
            return NSLocalizedString("Invalid message payload", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .invalidPhoneNumber:
            return NSLocalizedString("Invalid phone number", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .invalidRecipientEmail:
            return NSLocalizedString("Invalid recipient email", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .invalidSender:
            return NSLocalizedString("Invalid sender", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .invalidUserToken:
            return NSLocalizedString("Invalid user token", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .invalidVerificationCode:
            return NSLocalizedString("Invalid verification code", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .invalidVerificationID:
            return NSLocalizedString("Invalid verification ID", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .keychainError:
            return NSLocalizedString("Keychain error", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .malformedJWT:
            return NSLocalizedString("Malformed JWT", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .missingAndroidPackageName:
            return NSLocalizedString("Missing android package name", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .missingAppCredential:
            return NSLocalizedString("Missing app credential", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .missingAppToken:
            return NSLocalizedString("Missing app token", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .missingContinueURI:
            return NSLocalizedString("Missing continue URI", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .missingEmail:
            return NSLocalizedString("You need to register an email", comment: "CreateAccountViewController.swift AuthErrorCode")
       case .missingIosBundleID:
            return NSLocalizedString("Missing ios bundle ID", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .missingPhoneNumber:
            return NSLocalizedString("Missing phone number", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .missingVerificationCode:
            return NSLocalizedString("Missing verification code", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .missingVerificationID:
            return NSLocalizedString("Missing verification ID", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .networkError:
            return NSLocalizedString("Problem when trying to connect to the server", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .noSuchProvider:
            return NSLocalizedString("No such provider", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .notificationNotForwarded:
            return NSLocalizedString("Notification not forwarded", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .nullUser:
            return NSLocalizedString("Null user", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .operationNotAllowed:
            return NSLocalizedString("Operation not allowed", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .providerAlreadyLinked:
            return NSLocalizedString("Provider already linked", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .quotaExceeded:
            return NSLocalizedString("Quota exceeded", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .requiresRecentLogin:
            return NSLocalizedString("Requires recent login", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .sessionExpired:
            return NSLocalizedString("Session expired", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .tooManyRequests:
            return NSLocalizedString("Many requests have already been sent to the server", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .unauthorizedDomain:
            return NSLocalizedString("Unauthorized domain", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .userDisabled:
            return NSLocalizedString("This user has been disabled", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .userMismatch:
            return NSLocalizedString("User mismatch", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .userNotFound:
            return NSLocalizedString("There is no user record corresponding to this identifier", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .userTokenExpired:
            return NSLocalizedString("User token expired", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .weakPassword:
            return NSLocalizedString("Very weak or invalid password", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .webContextAlreadyPresented:
            return NSLocalizedString("Web context already presented", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .webContextCancelled:
            return NSLocalizedString("Web context cancelled", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .webInternalError:
            return NSLocalizedString("Web internal error", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .webNetworkRequestFailed:
            return NSLocalizedString("Web network request failed", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .wrongPassword:
            return NSLocalizedString("Incorrect password", comment: "CreateAccountViewController.swift AuthErrorCode")
        default:
            return nil
        }
    }
}

extension StorageErrorCode {
    var description: String? {
        switch self {
        case .bucketNotFound:
            return NSLocalizedString("Bo bucket is configured for Firebase Storage", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .cancelled:
            return NSLocalizedString("Operation cancelled", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .downloadSizeExceeded:
            return NSLocalizedString("Download size exceeds memory space", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .nonMatchingChecksum:
            return NSLocalizedString("Non matching checksum", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .objectNotFound:
            return NSLocalizedString("Object not found", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .projectNotFound:
            return NSLocalizedString("Project not found", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .quotaExceeded:
            return NSLocalizedString("The space to save files has been surpassed", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .retryLimitExceeded:
            return NSLocalizedString("Excessive waiting time Please try again", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .unauthenticated:
            return NSLocalizedString("Unauthenticated user", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .unknown:
            return NSLocalizedString("Unknown error", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .unauthorized:
            return NSLocalizedString("Unauthorized user to perform this operation", comment: "CreateAccountViewController.swift AuthErrorCode")
        default:
            return nil
        }
    } }

public extension Error {
    var localizedDescription: String {
        let error = self as NSError
        if error.domain == (AuthErrorDomain) {
            if let code = AuthErrorCode(rawValue: error.code) {
                if let errorString = code.description {
                    return errorString
                }
            }
        } else if error.domain == StorageErrorDomain {
            if let code = StorageErrorCode(rawValue: error.code) {
                if let errorString = code.description {
                    return errorString
                }
            }
        }
        return error.localizedDescription
    } }

