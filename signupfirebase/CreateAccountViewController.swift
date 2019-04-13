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
            
        }
        
        dismiss(animated: true, completion: nil)
    }
    
}

extension AuthErrorCode {
    var description: String? {
        switch self {
        case .accountExistsWithDifferentCredential:
            return NSLocalizedString("Indicates account linking is required.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .appNotAuthorized:
            return NSLocalizedString("Indicates the App is not authorized to use Firebase Authentication with the provided API Key.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .appNotVerified:
            return NSLocalizedString("Indicates that the app could not be verified by Firebase during phone number authentication.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .appVerificationUserInteractionFailure:
            return NSLocalizedString("Indicates a general failure during the app verification flow.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .captchaCheckFailed:
            return NSLocalizedString("Indicates that the reCAPTCHA token is not valid.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .credentialAlreadyInUse:
            return NSLocalizedString("Indicates an attempt to link with a credential that has already been linked with a different Firebase account", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .customTokenMismatch:
            return NSLocalizedString("Indicates the service account and the API key belong to different projects.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .emailAlreadyInUse:
            return NSLocalizedString("The email address is already in use by another account.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .expiredActionCode:
            return NSLocalizedString("Indicates the OOB code is expired", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .internalError:
            return NSLocalizedString("Internal error", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .invalidActionCode:
            return NSLocalizedString("Indicates the OOB code is invalid.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .invalidAPIKey:
            return NSLocalizedString("Indicates an invalid API key was supplied in the request.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .invalidAppCredential:
            return NSLocalizedString("Indicates that an invalid APNS device token was used in the verifyClient request.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .invalidClientID:
            return NSLocalizedString("Indicates that the clientID used to invoke a web flow is invalid.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .invalidContinueURI:
            return NSLocalizedString("Indicates that the domain specified in the continue URI is not valid.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .invalidCredential:
            return NSLocalizedString("Indicates the IDP token or requestUri is invalid.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .invalidCustomToken:
            return NSLocalizedString("Indicates a validation error with the custom token.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .invalidEmail:
            return NSLocalizedString("Indicates the email is invalid.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .invalidMessagePayload:
            return NSLocalizedString("Indicates that there are invalid parameters in the payload during a 'send password reset email' attempt.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .invalidPhoneNumber:
            return NSLocalizedString("Indicates that an invalid phone number was provided in a call to `verifyPhoneNumber:completion:`.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .invalidRecipientEmail:
            return NSLocalizedString("Indicates that the recipient email is invalid.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .invalidSender:
            return NSLocalizedString("Indicates that the sender email is invalid during a 'send password reset email' attempt.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .invalidUserToken:
            return NSLocalizedString("Indicates user's saved auth credential is invalid, the user needs to sign in again.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .invalidVerificationCode:
            return NSLocalizedString("ndicates that an invalid verification code was used in the verifyPhoneNumber request.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .invalidVerificationID:
            return NSLocalizedString("Indicates that an invalid verification ID was used in the verifyPhoneNumber request.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .keychainError:
            return NSLocalizedString("Indicates an error occurred while attempting to access the keychain.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .malformedJWT:
            return NSLocalizedString(" Raised when a JWT fails to parse correctly. May be accompanied by an underlying error describing which step of the JWT parsing process failed.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .missingAndroidPackageName:
            return NSLocalizedString("Indicates that the android package name is missing when the `androidInstallApp` flag is set to true.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .missingAppCredential:
            return NSLocalizedString("Indicates that the APNS device token is missing in the verifyClient request.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .missingAppToken:
            return NSLocalizedString("Indicates that the APNs device token could not be obtained. The app may not have set up remote notification correctly, or may fail to forward the APNs device FIRAuth                if app delegate swizzling is disabled.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .missingContinueURI:
            return NSLocalizedString("Indicates that a continue URI was not provided in a request to the backend which requires one.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .missingEmail:
            return NSLocalizedString("Indicates that an email address was expected but one was not provided.", comment: "CreateAccountViewController.swift AuthErrorCode")
       case .missingIosBundleID:
            return NSLocalizedString("Indicates that the iOS bundle ID is missing when a iOS App Store ID is provided.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .missingPhoneNumber:
            return NSLocalizedString("Indicates that a phone number was not provided in a call to `verifyPhoneNumber:completion:`.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .missingVerificationCode:
            return NSLocalizedString("Indicates that the phone auth credential was created with an empty verification code.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .missingVerificationID:
            return NSLocalizedString("Indicates that the phone auth credential was created with an empty verification ID.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .networkError:
            return NSLocalizedString("Indicates a network error occurred (such as a timeout, interrupted connection, or unreachable host). These types of errors are often recoverable with a retry. The                `NSUnderlyingError` field in the `NSError.userInfo` dictionary will contain the error encountered.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .noSuchProvider:
            return NSLocalizedString("Indicates an attempt to unlink a provider that is not linked.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .notificationNotForwarded:
            return NSLocalizedString("ndicates that the app fails to forward remote notification to FIRAuth.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .nullUser:
            return NSLocalizedString("Indicates that a non-null user was expected as an argmument to the operation but a null user was provided.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .operationNotAllowed:
            return NSLocalizedString("Indicates the administrator disabled sign in with the specified identity provider.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .providerAlreadyLinked:
            return NSLocalizedString("Indicates an attempt to link a provider to which the account is already linked.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .quotaExceeded:
            return NSLocalizedString("Indicates that the APNs device token could not be obtained. The app may not have set up remote notification correctly, or may fail to forward the APNs device token to FIRAuth if app delegate swizzling is disabled.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .requiresRecentLogin:
            return NSLocalizedString("Indicates the user has attemped to change email or password more than 5 minutes after signing in.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .sessionExpired:
            return NSLocalizedString("Indicates that the SMS code has expired.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .tooManyRequests:
            return NSLocalizedString("Indicates that too many requests were made to a server method.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .unauthorizedDomain:
            return NSLocalizedString("Indicates that the phone auth credential was created with an empty verification code.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .userDisabled:
            return NSLocalizedString("Indicates the user's account is disabled on the server.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .userMismatch:
            return NSLocalizedString("Indicates that an attempt was made to reauthenticate with a user which is not the current user.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .userNotFound:
            return NSLocalizedString("Indicates the user account was not found.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .userTokenExpired:
            return NSLocalizedString("Indicates the saved token has expired, for example, the user may have changed account password on another device. The user needs to sign in again on the device that made this request.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .weakPassword:
            return NSLocalizedString("Indicates an attempt to set a password that is considered too weak.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .webContextAlreadyPresented:
            return NSLocalizedString("Indicates that an attempt was made to present a new web context while one was already being presented.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .webContextCancelled:
            return NSLocalizedString("Indicates that the URL presentation was cancelled prematurely by the user.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .webInternalError:
            return NSLocalizedString("Indicates that an internal error occurred within a SFSafariViewController or UIWebview.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .webNetworkRequestFailed:
            return NSLocalizedString("Indicates that a network request within a SFSafariViewController or UIWebview failed.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .wrongPassword:
            return NSLocalizedString("Indicates the user attempted sign in with a wrong password.", comment: "CreateAccountViewController.swift AuthErrorCode")
        default:
            return nil
        }
    }
}

extension StorageErrorCode {
    var description: String? {
        switch self {
        case .bucketNotFound:
            return NSLocalizedString("No bucket is configured for Firebase Storage.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .cancelled:
            return NSLocalizedString("User cancelled the operation.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .downloadSizeExceeded:
            return NSLocalizedString("Size of the downloaded file exceeds the amount of memory allocated for the download. Increase memory cap and try downloading again.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .nonMatchingChecksum:
            return NSLocalizedString("File on the client does not match the checksum of the file received by the server. Try uploading again.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .objectNotFound:
            return NSLocalizedString("No object exists at the desired reference. ", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .projectNotFound:
            return NSLocalizedString("No project is configured for Firebase Storage.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .quotaExceeded:
            return NSLocalizedString("Quota on your Firebase Storage bucket has been exceeded. If you're on the free tier, upgrade to a paid plan. If you're on a paid plan, reach out to Firebase support.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .retryLimitExceeded:
            return NSLocalizedString("The maximum time limit on an operation (upload, download, delete, etc.) has been exceeded.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .unauthenticated:
            return NSLocalizedString("User is unauthenticated. Authenticate and try again.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .unknown:
            return NSLocalizedString("An unknown error occurred.", comment: "CreateAccountViewController.swift AuthErrorCode")
        case .unauthorized:
            return NSLocalizedString("User is not authorized to perform the desired action.", comment: "CreateAccountViewController.swift AuthErrorCode")
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

