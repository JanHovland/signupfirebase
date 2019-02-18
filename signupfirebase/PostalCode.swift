//
//  PostalCode.swift
//  signupfirebase
//
//  Created by Jan  on 21/01/2019.
//  Copyright © 2019 Jan . All rights reserved.
//

import Foundation

class PostalCode {
    var postPlace: String
    var postNumber: String
    var municipality: String
    var municipalityNumber: String
    
    
    init(postPlace: String,
         postNumber: String,
         municipality: String,
         municipalityNumber: String) {
        
        self.postPlace = postPlace
        self.postNumber = postNumber
        self.municipality = municipality
        self.municipalityNumber = municipalityNumber
    }
    
    convenience init() {
        self.init(postPlace: "",
                  postNumber: "",
                  municipality: "",
                  municipalityNumber: "")
    }
}
