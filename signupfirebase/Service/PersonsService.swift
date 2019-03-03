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
    
    func storePersonFiredata(id: String,
                             image: UIImage,
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
    
}
