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

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // In order to show both the icon and the text, the height of the tableViewCell must be > 91

        let deleteAction = UIContextualAction(style: .destructive, title: "") {
           (action, sourceView, completionHandler) in

            //            let record = self.personData[indexPath.row]
            //            self.database.delete(withRecordID: record.recordID) { (recordID, error) in
            //                DispatchQueue.main.async {
            //                    if (error != nil) {
            //                        print ("error")
            //                    } else {
            //                        print ("Posten er slettet")
            //                        self.personData.remove(at: indexPath.row)
            //                        self.tableView.deleteRows(at: [indexPath], with: .fade )
            //
            //                    }
            //                }
            //            }
        }

        // Customize the action buttons
        deleteAction.title = NSLocalizedString("Delete", comment: "MainPersonDataViewController trailingSwipeActionsConfigurationForRowAt")

        //        deleteAction.image = #imageLiteral(resourceName: "slett")
        //        deleteAction.backgroundColor = #colorLiteral(red: 1, green: 0.08195901584, blue: 0.1369091124, alpha: 1)

        deleteAction.image = #imageLiteral(resourceName: "delete")
        deleteAction.backgroundColor = .red

        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])

        return swipeConfiguration
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // In order to show both the icon and the text, the height of the tableViewCell must be > 91

        let updateAction = UIContextualAction(style: .normal, title: "") {
            (action, sourceView, completionHandler) in

            //            let record = self.personData[indexPath.row]
            //            self.database.delete(withRecordID: record.recordID) { (recordID, error) in
            //                DispatchQueue.main.async {
            //                    if (error != nil) {
            //                        print ("error")
            //                    } else {
            //                        print ("Posten er slettet")
            //                        self.personData.remove(at: indexPath.row)
            //                        self.tableView.deleteRows(at: [indexPath], with: .fade )
            //
            //                    }
            //                }
            //            }
        }

        // Customize the action buttons
        updateAction.title = NSLocalizedString("Update", comment: "MainPersonDataViewController leadingSwipeActionsConfigurationForRowAt")

        //        deleteAction.image = #imageLiteral(resourceName: "slett")
        //        deleteAction.backgroundColor = #colorLiteral(red: 1, green: 0.08195901584, blue: 0.1369091124, alpha: 1)

        updateAction.image = #imageLiteral(resourceName: "update-3")
        updateAction.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)

        let swipeConfiguration = UISwipeActionsConfiguration(actions: [updateAction])

        return swipeConfiguration
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
