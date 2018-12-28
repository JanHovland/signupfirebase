//
//  Posts.swift
//  teachfirebase
//
//  Created by Jan  on 30/10/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import Foundation

class Person {
    var id:String
    var author:UserProfile
    var name:String
    var address:String
    var dateOfBirth:String
    var gender:String
    var createdAt:Date
    
    init(id:String, author:UserProfile,
                    name:String,
                    address:String,
                    dateOfBirth:String,
                    gender:String,
                    timestamp:Double) {
        
        self.id = id
        self.author = author
        self.name = name
        self.address = address
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.createdAt = Date(timeIntervalSince1970: timestamp / 1000)
        
    }
}
