//
//  Persons.swift
//  signupfirebase
//
//  Created by Jan Hovland on 26/02/2019.
//  Copyright © 2019 Jan . All rights reserved.
//

import Foundation

struct person {
    
    // MARK: - Properties
    
    var personID: String
    var imageFileURL: String
    var user: String
    var votes: Int
    var timestamp: Int
    
    // MARK: - Firebase Keys
    
    enum personInfoKey {
        static let imageFileURL = "imageFileURL"
        static let user = "user"
        static let votes = "votes"
        static let timestamp = "timestamp"
    }
    
    
    // MARK: - Initialization
    
    init(personId: String,
         imageFileURL: String,
         user: String,
         votes: Int,
         timestamp: Int = Int(Date().timeIntervalSince1970 * 1000)) {
        
        self.personID = personId
        self.imageFileURL = imageFileURL
        self.user = user
        self.votes = votes
        self.timestamp = timestamp
    }
    
    init?(personId: String, personInfo: [String: Any]) {
        
        guard let imageFileURL = personInfo[personInfoKey.imageFileURL] as? String,
            let user = personInfo[personInfoKey.user] as? String,
            let votes = personInfo[personInfoKey.votes] as? Int,
            let timestamp = personInfo[personInfoKey.timestamp] as? Int else {
                return nil
            }
        
            self = person(personId: personId,
                          imageFileURL: imageFileURL,
                          user: user,
                          votes: votes,
                          timestamp: timestamp)
    }
    
}
