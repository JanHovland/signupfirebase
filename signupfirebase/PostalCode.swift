//
//  PostalCode.swift
//  signupfirebase
//
//  Created by Jan  on 21/01/2019.
//  Copyright © 2019 Jan . All rights reserved.
//

import Foundation

class PostalCode {
    var poststed: String
    var postnummer: String
    var kommune: String
    var kommunenummer: String
    
    
    init(poststed: String, postnummer: String, kommune: String, kommunenummer: String) {
        self.poststed = poststed
        self.postnummer = postnummer
        self.kommune = kommune
        self.kommunenummer = kommunenummer
    }
    
    convenience init() {
        self.init(poststed: "",
                  postnummer: "",
                  kommune: "",
                  kommunenummer: "")
    }
}
