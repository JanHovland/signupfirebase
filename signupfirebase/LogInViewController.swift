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


var imageReference: StorageReference {
    return Storage.storage().reference().child("images")
}

let filename = "firebase_logo.png"

class LogInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var activity: UIActivityIndicatorView!
    @IBOutlet var eMailLoginTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet weak var loginStatus: UITextField!
    
    @IBOutlet weak var uploadImage: UIImageView!
    @IBOutlet weak var downloadImage: UIImageView!

    var status: Bool = true
    var activeField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        let postDatabaseRef = Database.database().reference().child("posts")
        
        var postQuery =  postDatabaseRef.queryOrdered(byChild: "timestamp")
        postQuery = postQuery.queryLimited(toLast: 5)
        
        // postDatabaseRef.observeSingleEvent(of: .value, with:  { (snapshot) in
        postQuery.observeSingleEvent(of: .value, with:  { (snapshot) in
            print("Total number of posts: \(snapshot.childrenCount)")
            for item in snapshot.children.allObjects as! [DataSnapshot] {
                
                let postInfo = item.value as? [String: Any] ?? [:]
                
                print("----------")
                print("Post ID: \(item.key)")
                print("Image URL: \(postInfo["imageFileURL"] ?? "")")
                print("User: \(postInfo["user"] ?? "")")
                print("Votes: \(postInfo["votes"] ?? "")")
                print("Timestamp: \(postInfo["timestamp"] ?? "")")
            }
            
        })
        
        */
        
        PostService.shared.getRecentPosts(limit: 5) { (newPosts) in
            newPosts.forEach({ (post) in
                
                /*
                print("----------")
                print("Post ID: \(post.postID)")
                print("Image URL: \(post.imageFileURL)")
                print("User: \(post.user)")
                print("Votes: \(post.votes)")
                print("Timestamp: \(post.timestamp)")
                */
                
                if let url = URL(string: post.imageFileURL) {
                    
                    let downloadTask = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                        
                        guard let imageData = data else {
                            return
                        }
                        
                        OperationQueue.main.addOperation {
                            guard let image = UIImage(data: imageData) else {
                                return
                            }
                        
                            self.downloadImage.image = image
                            
                        }
                        
                    })
                    
                    downloadTask.resume()
                }
                
                
                
            })
            
            
        }
        
        
 
        // Hide the tabBar
        self.tabBarController?.tabBar.isHidden = true
        
        // Set "SHOWPASSWORD" to false
        UserDefaults.standard.set(false, forKey: "SHOWPASSWORD")
        
        // Set "LOGGEDIN" to false
        UserDefaults.standard.set(false, forKey: "LOGGEDIN")

        // Initialize the UIActivityIndicatorView
        activity.hidesWhenStopped = true
        activity.style = .gray
        view.addSubview(activity)

        // Start activity
        activity.startAnimating()

        // Get the last used eMail and password from CoreData where "loggedIn" = true
        // If no value, blank eMailLoginTextField and passwordTextField
        let value = getCoreData()
        
        //  0 = uid  1 = ePost  2 = name  3 = passWord)
        eMailLoginTextField.text = value.eMail
        passwordTextField.text = value.passWord

        activity.stopAnimating()
        
        // Turn off keyboard when you press "Return"
        eMailLoginTextField.delegate = self
        passwordTextField.delegate = self
        
    }
    
    @IBAction func uploadButton(_ sender: Any) {
        
        guard let image = uploadImage.image else { return }
        
        // Upload an image to the cloud
        PostService.shared.uploadImage(image: image) {
            self.dismiss(animated: true, completion: nil)
        }
    }
        
    override func viewDidAppear(_ animated: Bool) {
     
        // Hide the BackButton when returning from change/reset password
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        // Observe keyboard change
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeLogin(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeLogin(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeLogin(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        if (UserDefaults.standard.bool(forKey: "LOGGEDIN")) == true {
            loginStatus.text = showUserInfo(startUp: false)
        } else {
            loginStatus.text = showUserInfo(startUp: true)
        }
        
        if (UserDefaults.standard.bool(forKey: "SHOWPASSWORD")) == true {
            self.passwordTextField.isSecureTextEntry = false
        } else {
            self.passwordTextField.isSecureTextEntry = true
        }
        
        // Turn off keyboard when you press "Return"
        eMailLoginTextField.delegate = self
        passwordTextField.delegate = self
        
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
        var ok1: Bool = false
        var uid: String = ""
        var navn: String = ""

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
                    uid = Auth.auth().currentUser?.uid ?? ""
                    navn = Auth.auth().currentUser?.displayName ?? ""

                    // Reset all posts where 'loggedin' == true
                    ok = self.resetLoggedIinCoreData()

                    if ok == true {
                        // Check if the user exists in CoreData
                        // If not, store the user in CoreData
                        ok = self.findCoreData(withEpost: self.eMailLoginTextField.text!)

                        if ok == false {
                            ok1 = self.saveCoreData(withEpost: self.eMailLoginTextField.text!,
                                                    withPassord: self.passwordTextField.text!,
                                                    withUid: uid,
                                                    withLoggedIn: true,
                                                    withName: navn)

                            if ok1 == false {
                                let melding = NSLocalizedString("Unable to store data in FireBase.",
                                                       comment: "LoginViewVontroller.swift CheckLogin")
                                self.presentAlert(withTitle: NSLocalizedString("Error.",
                                                                               comment: "LoginViewVontroller.swift CheckLogin"),
                                                  message: melding)
                            }

                        } else {
                            // Find the password from CoreData, if it is differenr from Firedata, Update CoreData
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
                                UserDefaults.standard.set(true, forKey: "LOGGEDIN")
                                self.loginStatus.text = navn + NSLocalizedString(" is logged in.",
                                                                                 comment:"LoginViewVontroller.swift CheckLogin 'loggedin'")
                                
                                // Show the tabBar
                                self.tabBarController?.tabBar.isHidden = false
                                
                            }
                        }

                    } else {
                        let melding = NSLocalizedString("Unable to update CoreData.",
                                                        comment: "LoginViewVontroller.swift CheckLogin 'update'")
                        
                        self.presentAlert(withTitle: NSLocalizedString("Error",
                                                                       comment: "LoginViewVontroller.swift CheckLogin error"),
                                          message: melding)
                        
                    }

                } else {
                    self.presentAlertOption(withTitle: NSLocalizedString("Error",
                                                                         comment: "LoginViewVontroller.swift CheckLogin 'error'"),
                                            message: error!.localizedDescription as String)
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

}
