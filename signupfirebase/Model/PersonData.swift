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
    var dateOfBirth1: String            // 12. april 1976
    var dateOfBirth2: String            // 04-12         for å kunne sortere etter måned og dag
    var name: String
    var gender: Int
    var phoneNumber: String
    var postalCodeNumber: String
    var municipality: String
    var municipalityNumber: String
    var photoURL: String
    var firstName: String
    var lastName: String
    var personEmail: String
    
    init(address: String,
         city: String,
         dateOfBirth1: String,
         dateOfBirth2: String,
         name: String,
         gender: Int,
         phoneNumber: String,
         postalCodeNumber: String,
         municipality: String,
         municipalityNumber: String,
         photoURL: String,
         firstName: String,
         lastName: String,
         personEmail: String) {
        
        self.address = address
        self.city = city
        self.dateOfBirth1 = dateOfBirth1
        self.dateOfBirth2 = dateOfBirth2
        self.name = name
        self.gender = gender
        self.phoneNumber = phoneNumber
        self.postalCodeNumber = postalCodeNumber
        self.municipality = municipality
        self.municipalityNumber = municipalityNumber
        self.photoURL = photoURL
        self.firstName = firstName
        self.lastName = lastName
        self.personEmail = personEmail
        
    }
}
