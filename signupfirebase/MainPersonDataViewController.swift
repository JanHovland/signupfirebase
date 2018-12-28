//
//  MainPersonDataTableViewController.swift
//  signupfirebase
//
//  Created by Jan  on 23/12/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import UIKit
import CoreData
import FirebaseDatabase

class MainPersonDataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var persons = [Person]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Henter postene fra Firebase
        ReadPersonsFiredata()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
//        // Henter pålogget bruker
//        //  0 = uid  1 = ePost  2 = name  3 = passWord)
//        let value = getCoreData()
//
//        // Test av lagring av data i Firedata
//        SavePersonFiredata(uid: value.0,
//                           username: value.2,
//                           email: value.1,
//                           name: "Ole Olsen",
//                           address: "Uelandsgata 2",
//                           dateOfBirth: "01.01.1980",
//                           gender: "M"
//        )
//
//        // Henter postene fra Firebase
//        ReadPersonsFiredata()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return persons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell")
        
        /*
         
         Standard table view cell:
         
            When using table view cell of type "Basic" :
            cell?.textLabel?.text          :  "returns the label used for the main textual content of the table cell"
         
         
            When using table view cell of type "Right detail", "Left detail" and "Subtitle :
            cell?.textLabel?.text          :  "returns the label used for the main textual content of the table cell"
            cell?.detailTextLabel?.text    :  "returns the secondary label of the table cell if one exists
        
         */
        
        cell?.textLabel?.text = persons[indexPath.row].name
        cell?.detailTextLabel?.text = persons[indexPath.row].author.username
        
        return cell!

    }
    
    func ReadPersonsFiredata() {
        let personsRef = Database.database().reference().child("person")
        
        personsRef.observe(.value, with : { snapshot in
        
            var tempPersons = [Person]()
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                    let dict = childSnapshot.value as? [String:Any],
                    let author = dict["author"] as? [String:Any],
                    let uid = author["uid"] as? String,
                    let username = author["username"] as? String,
                    let email = author["email"] as? String,
                    let name = dict["name"] as? String,
                    let address = dict["address"] as? String,
                    let dateOfBirth = dict["dateOfBirth"] as? String,
                    let gender = dict["gender"] as? String,
                    let timestamp = dict["timestamp"] as? Double {
                    
                    let userProfile = UserProfile(uid: uid, username: username, email: email)
                    let person = Person(id: childSnapshot.key,
                                        author: userProfile,
                                        name: name,
                                        address: address,
                                        dateOfBirth: dateOfBirth,
                                        gender: gender,
                                        timestamp:timestamp)
                    
                    tempPersons.append(person)
                    
                }
                
            }
            
            // Oppdaterer posts array
            self.persons = tempPersons
            
            // Fyller ut table view
            self.tableView.reloadData()
            

        })
    }

}


