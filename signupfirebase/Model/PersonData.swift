//
//  PersonData.swift
//  signupfirebase
//
//  Created by Jan  on 02/01/2019.
//  Copyright © 2019 Jan . All rights reserved.
//

import Foundation
import UIKit

class PersonData {
    var address: String
    var city: String
    var dateOfBirth: String
    var name: String
    var gender: Int
    var phoneNumber: String
    var postalCodeNumber: String
    var municipality: String
    var municipalityNumber: String
    var photoURL: String
    
    init(address: String,
         city: String,
         dateOfBirth: String,
         name: String,
         gender: Int,
         phoneNumber: String,
         postalCodeNumber: String,
         municipality: String,
         municipalityNumber: String,
         photoURL: String) {
        
        self.address = address
        self.city = city
        self.dateOfBirth = dateOfBirth
        self.name = name
        self.gender = gender
        self.phoneNumber = phoneNumber
        self.postalCodeNumber = postalCodeNumber
        self.municipality = municipality
        self.municipalityNumber = municipalityNumber
        self.photoURL = photoURL
        
    }
}
