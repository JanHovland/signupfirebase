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
    var index: Bool
    
    init(code: String, city: String, index: Bool) {
        self.code = code
        self.city = city
        self.index = index
    }
    
    convenience init() {
        self.init(code: "", city: "", index: false)
    }
}
