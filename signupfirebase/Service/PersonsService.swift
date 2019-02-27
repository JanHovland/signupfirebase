//
//  PersonsService.swift
//  signupfirebase
//
//  Created by Jan Hovland on 26/02/2019.
//  Copyright © 2019 Jan . All rights reserved.
//

import Foundation
import Firebase

final class PersonService {
    
    // MARK: - Properties
    
    static let shared: PersonService = PersonService()
    private init() {}
    
    // Mark: - Firebase Database References
    
    let BASE_DB_REF: DatabaseReference = Database.database().reference()
    let PERSON_DB_REF: DatabaseReference = Database.database().reference().child("person")
    
    // MARK: - FirebaseStorage Reference
    
    let PHOTO_STORAGE_REF: StorageReference = Storage.storage().reference().child("photos")
    
    func uploadImage(image: UIImage,
                     user: String,
                     uid: String,
                     email: String,
                     address: String,
                     city: String,
                     dateOfBirth: String,
                     name: String,
                     gender: Int,
                     phoneNumber: String,
                     postalCodeNumber: String,
                     municipality: String,
                     municipalityNumber: String,
                     completionHandler: @escaping () -> Void) {
        
        // Generate an unique ID for the Persons and prepare the Persons reference
        let personDatabaseRef = PERSON_DB_REF.childByAutoId()
        
        // Use the unique key as the image name and prepare the storage reference
        guard let imageKey = personDatabaseRef.key else {
            return
        }
        
        let imageStorageRef = PHOTO_STORAGE_REF.child("\(imageKey).png")
        
        // Resize the image
        let scaledImage = image.scale(newWidth: 100.0)
        
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
                let imageFileURL = url.absoluteString
                let timestamp = Int(Date().timeIntervalSince1970 * 1000)
                
                let person: [String: Any] = [
                    
                    "author": [
                        "uid": uid,
                        "username": user,
                        "email": email,
                    ],
                    
                    "personData": [
                        "imageFileURL": imageFileURL,
                        "address": address,
                        "city": city,
                        "dateOfBirth": dateOfBirth,
                        "name": name,
                        "gender": gender,
                        "phoneNumber": phoneNumber,
                        "postalCodeNumber": postalCodeNumber,
                        "municipality": municipality,
                        "municipalityNumber": municipalityNumber,
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
            
            print("Uploading... \(percentComplete)% complete")
            
        }
        
        uploadTask.observe(.failure) { (snapshot) in
            
            if let error = snapshot.error {
                print(error.localizedDescription)
            }
            
        }
        
    }
    
    func getRecentPerson(start timestamp: Int? = nil, limit: UInt, completionHandler: @escaping ([person]) -> Void) {
        
        var personQuery = PERSON_DB_REF.queryOrdered(byChild: person.personInfoKey.timestamp)
        
        if let latestPersonTimestamp = timestamp, latestPersonTimestamp > 0 {
            // If the timestamp is specified, we will get the Persons with timestamp newer than the given value
            personQuery = personQuery.queryStarting(atValue: latestPersonTimestamp + 1,
                                                childKey: person.personInfoKey.timestamp).queryLimited(toLast: limit)
        } else {
            // Otherwise, we will just get the most recent Persons
            personQuery = personQuery.queryLimited(toLast: limit)
        }
        
        // Call Firebase API to retrieve the latest records
        personQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            var newPerson: [person] = []
            
            print("----------")
            print("Total number of Persons: \(snapshot.childrenCount)")
            
            for item in snapshot.children.allObjects as! [DataSnapshot] {
                let personInfo = item.value as? [String: Any] ?? [:]
                
                if let person = person(personId: item.key, personInfo: personInfo) {
                    newPerson.append(person)
                }
            }
            
            if newPerson.count > 0 {
                // Order in descending order (i.e. the latest Persons becomes the first Persons)
                newPerson.sort(by: {$0.timestamp > $1.timestamp})
            }
            
            completionHandler(newPerson)
            
        })
        
    }
    
}
