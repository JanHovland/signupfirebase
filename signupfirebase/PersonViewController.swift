//
//  PersonViewController.swift
//  signupfirebase
//
//  Created by Jan  on 28/12/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import UIKit

class PersonViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var firstNameInput: UITextField!
    @IBOutlet weak var lastNameInput: UITextField!
    @IBOutlet weak var addressInput: UITextField!
    @IBOutlet weak var phoneNumberInput: UITextField!
    @IBOutlet weak var zipCodeInput: UITextField!
    @IBOutlet weak var cityInput: UITextField!
    @IBOutlet weak var dateOfBirthInput: UITextField!
    @IBOutlet weak var genderInput: UISegmentedControl!

    @IBOutlet var activity: UIActivityIndicatorView!

    // These vaiables get their values from MainPersonDataViewController.swift
    var PersonFirstNameText = ""
    var PersonLastNameText = ""
    var PersonAddressText = ""
    var PersonPhoneNumberInput: UITextField!
    var PersonZipCodeInput: UITextField!
    var PersonCityInput: UITextField!

    var PersonDateOfBirthText = ""
    var PersonGenderInt = 0
    
    var PersonIdText = ""
    var PersonTitle = ""
    var PersonOption = 0 // 0 = save 1 = update

    let datoValg = UIDatePicker()

    var gender: String = NSLocalizedString("Man", comment: "PersonViewVontroller.swift velgeKjonn ")

    @IBOutlet var loginStatus: UILabel!

    var status: Bool = true
    var activeField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Change the title of navigationBar
        navigationItem.title = PersonTitle

        // Turn off keyboard when you press "Return"
        firstNameInput.delegate = self
        lastNameInput.delegate = self
        addressInput.delegate = self
        dateOfBirthInput.delegate = self

        // Initierer UIActivityIndicatorView
        activity.hidesWhenStopped = true
        activity.style = .gray
        view.addSubview(activity)
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

        firstNameInput.text = PersonFirstNameText
        lastNameInput.text = PersonLastNameText
        addressInput.text = PersonAddressText
        dateOfBirthInput.text = PersonDateOfBirthText

        if PersonGenderInt == 0 {
            genderInput.setTitle("Man", forSegmentAt: PersonGenderInt)
        } else if PersonGenderInt == 1 {
            genderInput.setTitle("Woman", forSegmentAt: PersonGenderInt)
        }

        genderInput.selectedSegmentIndex = PersonGenderInt

        // Convert PersonDateOfBirthText to the initial datoValg.date
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        let region = NSLocale.current.regionCode?.lowercased()
        formatter.locale = NSLocale(localeIdentifier: region!) as Locale
        if (PersonDateOfBirthText.count > 0) {
            let date = formatter.date(from: PersonDateOfBirthText)
            if date != nil {
                datoValg.date = date!
            }
        }
        
        // Get the selected date from the DatePicker
        hentFraDatoValg()
        
    }

    @objc func keyboardWillChangeAddPerson(notification: NSNotification) {
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
        firstNameInput.resignFirstResponder()
        lastNameInput.resignFirstResponder()
        addressInput.resignFirstResponder()
        dateOfBirthInput.resignFirstResponder()
    }

    @IBAction func SaveOrUpdatePerson(_ sender: Any) {
        // Get the user who has logged in
        //  0 = uid  1 = ePost  2 = name  3 = passWord)
        let value = getCoreData()

        let firstName = firstNameInput.text ?? ""
        let lastName = lastNameInput.text ?? ""
        
        let address = addressInput.text ?? ""
        let dateOfBirth = dateOfBirthInput.text ?? ""
        let gender = genderInput.selectedSegmentIndex

        activity.startAnimating()

        if PersonOption == 0 {
            savePersonFiredata(uid: value.0,
                               username: value.2,
                               email: value.1,
                               firstName: firstName,
                               lastName: lastName,
                               address: address,
                               dateOfBirth: dateOfBirth,
                               gender: gender)
        } else if PersonOption == 1 {
            updatePersonFiredata(id: PersonIdText,
                                 uid: value.0,
                                 username: value.2,
                                 email: value.1,
                                 firstName: firstName,
                                 lastName: lastName,
                                 address: address,
                                 dateOfBirth: dateOfBirth,
                                 gender: gender)
        }

        activity.stopAnimating()
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
        let region = NSLocale.current.regionCode?.lowercased()
        datoValg.locale = NSLocale(localeIdentifier: region!) as Locale
        
    }

    @objc func hentDatoValg() {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none

        let region = NSLocale.current.regionCode?.lowercased()
        formatter.locale = NSLocale(localeIdentifier: region!) as Locale

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
        case 0: gender = NSLocalizedString("Man", comment: "PersonViewVontroller.swift velgeKjonn ")
        case 1: gender = NSLocalizedString("Woman", comment: "PersonViewVontroller.swift velgeKjonn ")
        default: return
        }
    }
}
