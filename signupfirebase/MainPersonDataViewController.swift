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
        // Henter postene fra Firebase
        ReadPersonsFiredata()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return persons.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PersonDataTableViewCell

        /*

         Standard table view cell:

         When using table view cell of type "Basic" :
         cell?.textLabel?.text          :  "returns the label used for the main textual content of the table cell"

         When using table view cell of type "Right detail", "Left detail" and "Subtitle :
         cell?.textLabel?.text          :  "returns the label used for the main textual content of the table cell"
         cell?.detailTextLabel?.text    :  "returns the secondary label of the table cell if one exists

         */

        cell.nameLabel?.text = persons[indexPath.row].name
        cell.addressLabel?.text = persons[indexPath.row].address

        return cell
    }

    func ReadPersonsFiredata() {
        let personsRef = Database.database().reference().child("person")
        // let personsRef1 =  personsRef.queryOrdered(byChild: "name").queryEqual(toValue: "Ole Olsen")

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
                                        timestamp: timestamp)

                    tempPersons.append(person)
                }
            }

            // Oppdaterer posts array
            self.persons = tempPersons

            // Fyller ut table view
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
