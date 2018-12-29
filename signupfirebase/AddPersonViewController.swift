//
//  AddPersonViewController.swift
//  signupfirebase
//
//  Created by Jan  on 28/12/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import UIKit

class AddPersonViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var addressInput: UITextField!
    @IBOutlet weak var dateOfBirthInput: UITextField!
    @IBOutlet weak var genderInput: UISegmentedControl!
    
    @IBOutlet weak var loginStatus: UILabel!

    var status: Bool = true
    var activeField: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Observe keyboard change
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeLogin(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeLogin(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeLogin(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        // For å kunne avslutte visning av tastatur når en trykker "Ferdig" på tastaturet
        nameInput.delegate = self
        addressInput.delegate = self
        dateOfBirthInput.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if (UserDefaults.standard.bool(forKey: "LOGGEDIN")) == true {
            loginStatus.text = showUserInfo(startUp: false)
        } else {
            loginStatus.text = showUserInfo(startUp: true)
        }
        
    }
  
    @objc func keyboardWillChangeLogin(notification: NSNotification) {
        
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        print(view.frame.size.height)
        print((activeField?.frame.size.height)!)
        
        print((activeField?.frame.origin.y)!)
        
        let distanceToBottom = view.frame.size.height - (activeField?.frame.origin.y)! - (activeField?.frame.size.height)!
        
        print("distanceToBottom = \(distanceToBottom)")
        print("keyboardRect = \(keyboardRect.height)")
        
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
        print("LogInView1")
        activeField = textField
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("LogInView2")
        activeField?.resignFirstResponder()
        activeField = nil
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Dismiss the keyboard when the view is tapped on
        
        nameInput.resignFirstResponder()
        addressInput.resignFirstResponder()
        dateOfBirthInput.resignFirstResponder()
    }
    
    @IBAction func SaveNewPerson(_ sender: Any) {
        
        // Henter pålogget bruker
        //  0 = uid  1 = ePost  2 = name  3 = passWord)
        let value = getCoreData()

        let name = nameInput.text ?? ""
        let address = addressInput.text ?? ""
        let dateOfBirth = dateOfBirthInput.text ?? ""
        let gender = "Mann"  // genderInput som en streng
        
        SavePersonFiredata(uid: value.0,
                           username: value.2,
                           email: value.1,
                           name: name,
                           address: address,
                           dateOfBirth: dateOfBirth,
                           gender: gender
        )
        
    }
    
}
