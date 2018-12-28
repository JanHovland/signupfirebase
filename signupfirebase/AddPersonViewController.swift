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
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func SaveNewPerson(_ sender: Any) {
        
        // Henter pålogget bruker
        //  0 = uid  1 = ePost  2 = name  3 = passWord)
        let value = getCoreData()

        let name = nameInput.text ?? ""
        let address = addressInput.text ?? ""
        let dateOfBirth = dateOfBirthInput.text ?? ""
        let gender = "Mann"  // genderInput somen streng 
        
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
