//
//  PostalCode.swift
//  signupfirebase
//
//  Created by Jan  on 21/01/2019.
//  Copyright © 2019 Jan . All rights reserved.
//

import Foundation

class PostalCode {
    var postnummer: String
    var poststed: String
    var kommunenummer: String
    var kommune: String
    
    
    init(postnummer: String, poststed: String, kommunenummer: String, kommune: String) {
        self.postnummer = postnummer
        self.poststed = poststed
        self.kommunenummer = kommunenummer
        self.kommune = kommune
    }
    
    convenience init() {
        self.init(postnummer: "",
                  poststed: "",
                  kommunenummer: "",
                  kommune: "")
    }
}
