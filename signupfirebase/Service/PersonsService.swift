//
//  PersonsService.swift
//  signupfirebase
//
//  Created by Jan Hovland on 26/02/2019.
//  Copyright © 2019 Jan . All rights reserved.
//

import Foundation
import Firebase

var percentFinished: Double = 0.0

final class PersonService {
    
    // MARK: - Properties
    
    static let shared: PersonService = PersonService()
    private init() {}
    
    // Mark: - Firebase Database References
    
    let BASE_DB_REF: DatabaseReference = Database.database().reference()
    let PERSON_DB_REF: DatabaseReference = Database.database().reference().child("person")
    
    // MARK: - FirebaseStorage Reference
    
    let PHOTO_STORAGE_REF: StorageReference = Storage.storage().reference().child("photos")
    
    func storePersonFiredata(id: String,
                             photoURL: String,
                             image: UIImage,
                             user: String,
                             uid: String,
                             email: String,
                             address: String,
                             city: String,
                             dateOfBirth1: String,
                             dateOfBirth2: String,
                             name: String,
                             gender: Int,
                             phoneNumber: String,
                             postalCodeNumber: String,
                             municipality: String,
                             municipalityNumber: String,
                             firstName: String,
                             lastName: String,
                             personEmail: String,
                             completionHandler: @escaping () -> Void) {
        
        var dbRef: DatabaseReference
        
        if id.count == 0 {
            // Generate an unique ID for the Persons and prepare the Persons reference
            dbRef = PERSON_DB_REF.childByAutoId()
        } else {
            dbRef = BASE_DB_REF.child("person" + "/" + id)
        }
        
        let personDatabaseRef = dbRef
        
        // Use the unique key as the image name and prepare the storage reference
        guard let imageKey = personDatabaseRef.key else {
            return
        }
        
        let imageStorageRef = PHOTO_STORAGE_REF.child("\(imageKey).png")
        
        // Resize the image
        let scaledImage = image.scale(newWidth: 25.0)
        
        guard let imageData = scaledImage.jpegData(compressionQuality: 0.9) else {
            return
        }
        
        // Create the file metadata
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
        // Prepare the upload task
        let uploadTask = imageStorageRef.putData(imageData, metadata: metadata)
        
        // Prepare the upload status
        uploadTask.observe(.success) { (snapshot) in
            
            // Add a reference in the database
            snapshot.reference.downloadURL(completion: { (url, error) in
                guard let url = url else {
                    return
                }
                
                // Add a reference in the database
                let personPhotoURL = url.absoluteString
                let timestamp = Int(Date().timeIntervalSince1970 * 1000)
                
                let person: [String: Any] = [
                    
                    "author": [
                        "uid": uid,
                        "username": user,
                        "email": email,
                        "photoURL": photoURL,
                    ],
                    
                    "personData": [
                        "photoURL": personPhotoURL,
                        "address": address,
                        "city": city,
                        "dateOfBirth1": dateOfBirth1,
                        "dateOfBirth2": self.convertStringDate(stringDate: dateOfBirth1),
                        "name": name,
                        "gender": gender,
                        "phoneNumber": phoneNumber,
                        "postalCodeNumber": postalCodeNumber,
                        "municipality": municipality,
                        "municipalityNumber": municipalityNumber,
                        "firstName": firstName,
                        "lastName": lastName,
                        "personEmail": personEmail,
                    ],
                    
                    "timestamp": timestamp,
                    
                    ]
                
                personDatabaseRef.setValue(person)
                
            })
            
            completionHandler()
            
        }
        
        uploadTask.observe(.progress) { (snapshot) in
            
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) /
                Double(snapshot.progress!.totalUnitCount)
 
            // Update the global variable 
            percentFinished = percentComplete
            
        }
        
        uploadTask.observe(.failure) { (snapshot) in
            
            if let error = snapshot.error {
                print(error.localizedDescription)
            }
            
        }
        
    }
    
    // Converts "12. april 1976" to "04-12"
    func convertStringDate(stringDate: String) -> String {
        
        var day: String = ""
        var month: String = ""
        
        if let space = stringDate.lastIndex(of: " ") {
            
            let str1 = stringDate[..<space]
            
            print("str1 = \(str1)")
            
            if let periode = str1.firstIndex(of: ".") {
                
                let day1 = stringDate[..<periode]
                
                day = String(day1)
                
                if day.count == 1 {
                    day = "0" + day
                }
                
                print("day = \(day)")
                
                if let space1 = str1.firstIndex(of: " ") {
                    
                    let month1 = str1[space1...]
                    
                    let month2 = month1.replacingOccurrences(of: " ", with: "")
                    
                    let month3 = String(month2)
                    
                    if month3         == NSLocalizedString("january", comment: "LogInViewController.swift CheckLogin verdi") {
                        month = "01"
                    } else if  month3 == NSLocalizedString("february", comment: "LogInViewController.swift CheckLogin verdi") {
                        month = "02"
                    } else if  month3 == NSLocalizedString("march", comment: "LogInViewController.swift CheckLogin verdi") {
                        month = "03"
                    } else if  month3 == NSLocalizedString("april", comment: "LogInViewController.swift CheckLogin verdi") {
                        month = "04"
                    } else if  month3 == NSLocalizedString("may", comment: "LogInViewController.swift CheckLogin verdi") {
                        month = "05"
                    } else if  month3 == NSLocalizedString("june", comment: "LogInViewController.swift CheckLogin verdi") {
                        month = "06"
                    } else if  month3 == NSLocalizedString("july", comment: "LogInViewController.swift CheckLogin verdi") {
                        month = "07"
                    } else if  month3 == NSLocalizedString("august", comment: "LogInViewController.swift CheckLogin verdi") {
                        month = "08"
                    } else if  month3 == NSLocalizedString("september", comment: "LogInViewController.swift CheckLogin verdi") {
                        month = "09"
                    } else if  month3 == NSLocalizedString("october", comment: "LogInViewController.swift CheckLogin verdi") {
                        month = "10"
                    } else if  month3 == NSLocalizedString("november", comment: "LogInViewController.swift CheckLogin verdi") {
                        month = "11"
                    } else if  month3 == NSLocalizedString("december", comment: "LogInViewController.swift CheckLogin verdi") {
                        month = "12"
                    }
                    
                    print("month = \(month)")
                    
                    return month + "-" + day
                    
                }
                
            }
            
        }
        
        return month + "-" + day
    }
    
    
}
