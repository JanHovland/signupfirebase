//
//  PersonViewController.swift
//  signupfirebase
//
//  Created by Jan  on 28/12/2018.
//  Copyright © 2018 Jan . All rights reserved.
//
import UIKit
import Firebase

class PersonViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var addressInput: UITextField!
    @IBOutlet var cityInput: UITextField!
    @IBOutlet var dateOfBirthInput: UITextField!
    @IBOutlet var nameInput: UITextField!
    @IBOutlet var genderInput: UISegmentedControl!
    @IBOutlet var phoneNumberInput: UITextField!
    @IBOutlet var postalCodeNumberInput: UITextField!
    @IBOutlet weak var municipalityNumberInput: UITextField!
    @IBOutlet weak var municipalityInput: UITextField!
    
    @IBOutlet var inputImage: UIImageView! {
        didSet {
            inputImage.layer.cornerRadius = inputImage.bounds.width / 2
            inputImage.clipsToBounds = true
        }
    }
   
    @IBOutlet var activity: UIActivityIndicatorView!
    
    var PersonTitle = ""
    var PersonOption = 0 // 0 = save 1 = update
    
    // These vaiables get their values from MainPersonDataViewController.swift
    var PersonPhotoURL = ""
    var PersonIdText = ""
    var PersonAddressText = ""
    var PersonCityText = ""
    var PersonDateOfBirthText = ""
    var PersonNameText = ""
    var PersonGenderInt = 0
    var PersonPhoneNumberText = ""
    var PersonPostalCodeNumberText = ""
    var PersonMunicipalityText = ""
    var PersonMunicipalityNumberText = ""
    
    let datoValg = UIDatePicker()
    
    var gender: String = NSLocalizedString("Man", comment: "PersonViewVontroller.swift velgeKjonn ")
    
    @IBOutlet var loginStatus: UILabel!
    
    var status: Bool = true
    var activeField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change the title of navigationBar
        navigationItem.title = PersonTitle
        
        // Show "log in"
        loginStatus.text = showUserInfo(startUp: true)
        
        // Turn off keyboard when you press "Return"
        addressInput.delegate = self
        cityInput.delegate = self
        nameInput.delegate = self
        dateOfBirthInput.delegate = self
        phoneNumberInput.delegate = self
        postalCodeNumberInput.delegate = self
        
        municipalityNumberInput.delegate = self
        municipalityInput.delegate = self
        
        // Initierer UIActivityIndicatorView
        activity.hidesWhenStopped = true
        activity.style = .gray
        view.addSubview(activity)
        
        // Set the global variables
        globalCity = cityInput.text!
        globalPostalCode = postalCodeNumberInput.text!
        
        globalMunicipality = municipalityInput.text!
        globalMunicipalityNumber = municipalityNumberInput.text!
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Show the Navigation Bar
        navigationController?.setNavigationBarHidden(false, animated: true)
        postalCodeNumberInput.text! = globalPostalCode
        cityInput.text! = globalCity
        
        municipalityNumberInput.text! = globalMunicipalityNumber
        municipalityInput.text =  globalMunicipality
        
        // Find the inputImage before updating the person data
        
        if let image = CacheManager.shared.getFromCache(key: PersonPhotoURL) as? UIImage {
            self.inputImage.image = image
            self.PersonPhotoURL = ""
        } else {
            if let url = URL(string: PersonPhotoURL) {
                
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
                        CacheManager.shared.cache(object: image, key: self.PersonPhotoURL)
                        self.PersonPhotoURL = ""
                    }
                })
                
                findCellImage.resume()
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        // Observe keyboard change
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeAddPerson(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeAddPerson(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeAddPerson(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
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
        
        municipalityNumberInput.text! =  PersonMunicipalityNumberText
        municipalityInput.text = PersonMunicipalityText
        
        if globalCity.count > 0 {
            cityInput.text = globalCity
        }
        
        if globalPostalCode.count > 0 {
            postalCodeNumberInput.text = globalPostalCode
        }
        
        if globalMunicipality.count > 0 {
            municipalityInput.text = globalMunicipality
        }
        
        if globalMunicipalityNumber.count > 0 {
            municipalityNumberInput.text = globalMunicipalityNumber
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
        
        municipalityNumberInput.resignFirstResponder()
        municipalityInput.resignFirstResponder()
        
    }
    
    @IBAction func uploadPersonFiredata(_ sender: Any) {
        
        guard let image = inputImage.image else { return }
        
        // Get the user who has logged in
        //  0 = uid  1 = eMail  2 = name  3 = passWord 4 = photoURL
        let value = getCoreData()
        
        
        // Upload an image to the cloud
        PersonService.shared.storePersonFiredata(id: PersonIdText,
                                                 photoURL: value.photoURL,
                                                 image: image,
                                                 user: value.name,
                                                 uid: value.uid,
                                                 email: value.eMail,
                                                 address: addressInput.text!,
                                                 city: cityInput.text!,
                                                 dateOfBirth: dateOfBirthInput.text!,
                                                 name: nameInput.text!.uppercased(),
                                                 gender: genderInput.selectedSegmentIndex,
                                                 phoneNumber: phoneNumberInput.text!,
                                                 postalCodeNumber: postalCodeNumberInput.text!,
                                                 municipality: municipalityInput.text!,
                                                 municipalityNumber: municipalityNumberInput.text!) {
                                                    self.dismiss(animated: true, completion: nil)
        }
        
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
        dateOfBirthInput.text =  "\(datoString)"
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 'prepare' will run after every segue.
        if segue.identifier! == "gotoPostalCodes" {
            let vc = segue.destination as! PostalCodeSearchTableViewController
            
            let name1 = nameInput.text!.lowercased()
            let name = name1.capitalized
            
            vc.postalCodeNameText = name
            vc.postalCodeAddressText = addressInput.text!
            vc.postalCodePhoneNumberText = phoneNumberInput.text!
            vc.postalCodePostalCodeNumberText = postalCodeNumberInput.text!
            vc.postalCodeCityText = cityInput.text!
            vc.postalCodeDateOfBirthText = dateOfBirthInput.text!
            vc.postalCodeGenderInt = PersonGenderInt
            vc.postalCodeMunicipalityText = municipalityInput.text!
            vc.postalCodeMunicipalityNumberText = municipalityNumberInput.text!
            
        }
    }
    
}
