//
//  PostalCode.swift
//  signupfirebase
//
//  Created by Jan  on 21/01/2019.
//  Copyright © 2019 Jan . All rights reserved.
//

import Foundation

class PostalCode {
    var code: String
    var city: String
    
    init(code: String, city: String) {
        self.code = code
        self.city = city
    }
    
    convenience init() {
        self.init(code: "",
                  city: "")
    }
}
