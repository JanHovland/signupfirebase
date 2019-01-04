//
//  AddPersonViewController.swift
//  signupfirebase
//
//  Created by Jan  on 28/12/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import UIKit

class AddPersonViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var nameInput: UITextField!
    @IBOutlet var addressInput: UITextField!
    @IBOutlet var dateOfBirthInput: UITextField!
    @IBOutlet var genderInput: UISegmentedControl!

    let datoValg = UIDatePicker()

    var gender: String = "Mann"

    @IBOutlet var loginStatus: UILabel!

    var status: Bool = true
    var activeField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // For å kunne avslutte visning av tastatur når en trykker "Ferdig" på tastaturet
        nameInput.delegate = self
        addressInput.delegate = self
        dateOfBirthInput.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        // Observe keyboard change
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeAddPerson(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeAddPerson(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeAddPerson(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        if (UserDefaults.standard.bool(forKey: "LOGGEDIN")) == true {
            loginStatus.text = showUserInfo(startUp: false)
        } else {
            loginStatus.text = showUserInfo(startUp: true)
        }

        // Legg inn fra datovalg
        hentFraDatoValg()
    }

    @objc func keyboardWillChangeAddPerson(notification: NSNotification) {
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }

//        print(view.frame.size.height)
//        print((activeField?.frame.size.height)!)
//        print((activeField?.frame.origin.y)!)
//        print("distanceToBottom = \(distanceToBottom)")
//        print("keyboardRect = \(keyboardRect.height)")

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
        let gender = "Mann" // genderInput som en streng

        SavePersonFiredata(uid: value.0,
                           username: value.2,
                           email: value.1,
                           name: name,
                           address: address,
                           dateOfBirth: dateOfBirth,
                           gender: gender
        )
    }

    func hentFraDatoValg() {
        let toolBarDatoValg = UIToolbar()
        toolBarDatoValg.sizeToFit()
        
        let flexibleSpaceDatoValg = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)

        let ferdigButtonDatoValg = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done,
                                                   target: self, action: #selector(hentDatoValg))
        
        toolBarDatoValg.setItems([flexibleSpaceDatoValg, ferdigButtonDatoValg], animated: false)

        dateOfBirthInput.inputAccessoryView = toolBarDatoValg
        dateOfBirthInput.inputView = datoValg
        datoValg.datePickerMode = .date
        
        let currentLocale = NSLocale.current.regionCode             //  <-------- returnerer "NO"
        datoValg.locale = NSLocale.init(localeIdentifier: currentLocale!) as Locale
        
    }

    @objc func hentDatoValg() {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        let currentLocale = NSLocale.current.regionCode
        
        formatter.locale = NSLocale.init(localeIdentifier: currentLocale!) as Locale
        
        let datoString = formatter.string(from: datoValg.date)
        dateOfBirthInput.text = "\(datoString)"
        view.endEditing(true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        // Remove observers
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    @IBAction func velgeKjonn(_ sender: UISegmentedControl) {
        switch genderInput.selectedSegmentIndex {
        case 0: gender = "Mann"
        case 1: gender = "Kvinne"
        default: return
        }
    }
}
