//
//  UserProfile.swift
//  teachfirebase
//
//  Created by Jan  on 30/10/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import Foundation

class Author {
    var uid: String
    var username: String
    var email: String
    var photoURL: String
    
    init(uid: String,
         username: String,
         email: String,
         photoURL: String) {
        
        self.uid = uid
        self.username = username
        self.email = email
        self.photoURL = photoURL
        
    }
}
