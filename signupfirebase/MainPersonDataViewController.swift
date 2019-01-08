//
//  MainPersonDataTableViewController.swift
//  signupfirebase
//
//  Created by Jan  on 23/12/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import CoreData
import FirebaseDatabase
import UIKit

/*

 Firebase rules:

 {
    "rules": {
          "person": {
                    ".read": "auth.uid != null",
                    ".write": "auth.uid != null",
                    ".indexOn" : ["uid", "name", "address", "dateOfBirth"]
          }
    }
 }

 
 // let personsRef1 =  personsRef.queryOrdered(byChild: "name").queryEqual(toValue: "Ole Olsen")
 */

class MainPersonDataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!

    var persons = [Person]()
    var activeField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
    }

    override func viewDidAppear(_ animated: Bool) {
        // Get the posts from Firebase
        ReadPersonsFiredata()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return persons.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PersonDataTableViewCell

        cell.nameLabel?.text = persons[indexPath.row].personData.name
        cell.addressLabel?.text = persons[indexPath.row].personData.address

        return cell
    }

    func ReadPersonsFiredata() {
        let personsRef = Database.database().reference().child("person")

        personsRef.observe(.value, with: { snapshot in

            var tempPersons = [Person]()

            for child in snapshot.children {
                print("child = \(child)")

                if let childSnapshot = child as? DataSnapshot,
                    let dict = childSnapshot.value as? [String: Any],
                    let author = dict["author"] as? [String: Any],
                    let uid = author["uid"] as? String,
                    let username = author["username"] as? String,
                    let email = author["email"] as? String,

                    let personData = dict["personData"] as? [String: Any],
                    let name = personData["name"] as? String,
                    let address = personData["address"] as? String,
                    let dateOfBirth = personData["dateOfBirth"] as? String,
                    let gender = personData["gender"] as? String,

                    let timestamp = dict["timestamp"] as? Double {
                    let author = Author(uid: uid,
                                        username: username,
                                        email: email)

                    let personData = PersonData(address: address,
                                                dateOfBirth: dateOfBirth,
                                                gender: gender,
                                                name: name)

                    let person = Person(id: childSnapshot.key,
                                        author: author,
                                        personData: personData,
                                        timestamp: timestamp)

                    tempPersons.append(person)
                }
            }

            // Update the posts array
            self.persons = tempPersons

            // Fill the table view
            self.tableView.reloadData()

        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        // Remove observers
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
}
