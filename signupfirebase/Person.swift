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
    var author: Author
    var personData: PersonData
    var createdAt:Date
    
    init(id:String,
         author:Author,
         personData:PersonData,
         timestamp:Double) {
        
        self.id = id
        self.author = author
        self.personData = personData
        self.createdAt = Date(timeIntervalSince1970: timestamp / 1000)
        
    }
}
