//
//  PersonViewController.swift
//  signupfirebase
//
//  Created by Jan  on 28/12/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import UIKit

class PersonViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var addressInput: UITextField!
    @IBOutlet var cityInput: UITextField!
    @IBOutlet var dateOfBirthInput: UITextField!
    @IBOutlet var nameInput: UITextField!
    @IBOutlet var genderInput: UISegmentedControl!
    @IBOutlet var phoneNumberInput: UITextField!
    @IBOutlet var postalCodeNumberInput: UITextField!

    @IBOutlet var activity: UIActivityIndicatorView!

    var PersonTitle = ""
    var PersonOption = 0 // 0 = save 1 = update

    // These vaiables get their values from MainPersonDataViewController.swift
    var PersonIdText = ""
    var PersonAddressText = ""
    var PersonCityText = ""
    var PersonDateOfBirthText = ""
    var PersonNameText = ""
    var PersonGenderInt = 0
    var PersonPhoneNumberText = ""
    var PersonPostalCodeNumberText = ""

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
        addressInput.delegate = self
        cityInput.delegate = self
        nameInput.delegate = self
        dateOfBirthInput.delegate = self
        phoneNumberInput.delegate = self
        postalCodeNumberInput.delegate = self

        // Initierer UIActivityIndicatorView
        activity.hidesWhenStopped = true
        activity.style = .gray
        view.addSubview(activity)

        // Set the global variables
        city = cityInput.text!
        postalCode = postalCodeNumberInput.text!
    }

    override func viewWillAppear(_ animated: Bool) {
        // Show the Navigation Bar
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)

        // Observe keyboard change
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeAddPerson(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeAddPerson(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeAddPerson(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        if (UserDefaults.standard.bool(forKey: "LOGGEDIN")) == true {
            loginStatus.text = showUserInfo(startUp: false)
        } else {
            loginStatus.text = showUserInfo(startUp: true)
        }

        if globalPersonAddressText.count > 0 {
            addressInput.text = globalPersonAddressText
        } else {
            addressInput.text = PersonAddressText
        }

        if globalPersonDateOfBirthText.count > 0 {
            dateOfBirthInput.text = globalPersonDateOfBirthText
        } else {
            dateOfBirthInput.text = PersonDateOfBirthText
        }

        // Use the global variables been set in PostalCodeSearchViewController
        if globalPersonNameText.count > 0 {
            nameInput.text = globalPersonNameText
        } else {
            nameInput.text = PersonNameText
        }

        if globalPersonGenderInt != -1 {
            if globalPersonGenderInt == 0 {
                genderInput.setTitle(NSLocalizedString("Man", comment: "PersonViewVontroller.swift viewDidAppear "),
                                     forSegmentAt: globalPersonGenderInt)
            } else if globalPersonGenderInt == 1 {
                genderInput.setTitle(NSLocalizedString("Woman", comment: "PersonViewVontroller.swift viewDidAppear "),
                                     forSegmentAt: globalPersonGenderInt)
                genderInput.selectedSegmentIndex = globalPersonGenderInt
            }
        } else {
            if PersonGenderInt == 0 {
                genderInput.setTitle(NSLocalizedString("Man", comment: "PersonViewVontroller.swift viewDidAppear "),
                                     forSegmentAt: PersonGenderInt)
            } else if PersonGenderInt == 1 {
                genderInput.setTitle(NSLocalizedString("Woman", comment: "PersonViewVontroller.swift viewDidAppear "),
                                     forSegmentAt: PersonGenderInt)
            }
            genderInput.selectedSegmentIndex = PersonGenderInt
        }

        if globalPersonNameText.count > 0 {
            nameInput.text = globalPersonNameText
        } else {
            nameInput.text = PersonNameText
        }

        if globalPersonPhoneNumberText.count > 0 {
            phoneNumberInput.text = globalPersonPhoneNumberText

        } else {
            phoneNumberInput.text = PersonPhoneNumberText
        }

        cityInput.text = PersonCityText
        postalCodeNumberInput.text = PersonPostalCodeNumberText

        if city.count > 0 {
            cityInput.text = city
            postalCodeNumberInput.text = postalCode
        }

        // Convert PersonDateOfBirthText to the initial datoValg.date
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        let region = NSLocale.current.regionCode?.lowercased()
        formatter.locale = NSLocale(localeIdentifier: region!) as Locale
        if PersonDateOfBirthText.count > 0 {
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

        if activeField != nil {
        
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
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Dismiss the keyboard when the return button on the keyboard is pressed
        
        if textField.text! == phoneNumberInput.text! {
            phoneNumberInput.text = formatPhone(phone: phoneNumberInput.text!)
        }
        activeField?.resignFirstResponder()
        activeField = nil
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Dismiss the keyboard when the view is tapped on
        addressInput.resignFirstResponder()
        cityInput.resignFirstResponder()
        nameInput.resignFirstResponder()
        dateOfBirthInput.resignFirstResponder()
        phoneNumberInput.resignFirstResponder()
        phoneNumberInput.text = formatPhone(phone: phoneNumberInput.text!)
        postalCodeNumberInput.resignFirstResponder()
    }

    @IBAction func SaveOrUpdatePerson(_ sender: Any) {
        // Get the user who has logged in
        //  0 = uid  1 = ePost  2 = name  3 = passWord)
        let value = getCoreData()

        let address = addressInput.text ?? ""
        let city = cityInput.text ?? ""
        let dateOfBirth = dateOfBirthInput.text ?? ""
        let name = nameInput.text ?? ""
        let gender = genderInput.selectedSegmentIndex
        
        // Check the telephone number
        let phoneNumber = formatPhone(phone: phoneNumberInput.text!)
 
        let postalCodeNumber = postalCodeNumberInput.text ?? ""

        activity.startAnimating()

        if PersonOption == 0 {
            savePersonFiredata(uid: value.0,
                               username: value.2,
                               email: value.1,
                               address: address,
                               city: city,
                               dateOfBirth: dateOfBirth,
                               name: name,
                               gender: gender,
                               phoneNumber: phoneNumber,
                               postalCodeNumber: postalCodeNumber)

        } else if PersonOption == 1 {
            updatePersonFiredata(id: PersonIdText,
                                 uid: value.0,
                                 username: value.2,
                                 email: value.1,
                                 address: address,
                                 city: city,
                                 dateOfBirth: dateOfBirth,
                                 name: name,
                                 gender: gender,
                                 phoneNumber: phoneNumber,
                                 postalCodeNumber: postalCodeNumber)
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

    @IBAction func buttonPhone(_ sender: Any) {
        print(phoneNumberInput.text!)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 'prepare' will run after every segue.

        if segue.identifier! == "goToPostalCodes" {
            let vc = segue.destination as! PostalCodeSearchTableViewController

            vc.postalCodeNameText = nameInput.text!
            vc.postalCodeAddressText = addressInput.text!
            vc.postalCodePhoneNumberText = phoneNumberInput.text!
            vc.postalCodePostalCodeNumberText = postalCodeNumberInput.text!
            vc.postalCodeCityText = cityInput.text!
            vc.postalCodeDateOfBirthText = dateOfBirthInput.text!
            vc.postalCodeGenderInt = PersonGenderInt
        }
    }
}
