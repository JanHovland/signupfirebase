//
//  MainPersonDataTableViewController.swift
//  signupfirebase
//
//  Created by Jan  on 23/12/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import Firebase         // Database
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

 This is working:
 
 {
 "rules": {
 "person": {
 ".read": "auth.uid != null",
 ".write": "auth.uid != null",
 ".indexOn" : "personData/name"
 }
 }
 }
 
 
 */

class MainPersonDataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!

    var persons = [Person]()
    var activeField: UITextField!
    
    var indexRowUpdateSwipe  = -1

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewDidAppear(_ animated: Bool) {
        // Get the posts from Firebase
        ReadPersonsFiredata(search: false, searchValue: "") 
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

            // Find the id of the post
            let id = self.persons[indexPath.row].id

            let dataBase = Database.database().reference().child("person" + "/" + id)
     
            dataBase.setValue(nil)
    
        }
        
        // Customize the action buttons
        deleteAction.title = NSLocalizedString("Delete", comment: "MainPersonDataViewController trailingSwipeActionsConfigurationForRowAt")

        deleteAction.image = #imageLiteral(resourceName: "trash-35")
        deleteAction.backgroundColor = .red
      
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])

        return swipeConfiguration
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // In order to show both the icon and the text, the height of the tableViewCell must be > 91
        let updateAction = UIContextualAction(style: .normal, title: "") {
            (action, sourceView, completionHandler) in
            
            self.indexRowUpdateSwipe = indexPath.row
            self.performSegue(withIdentifier: "gotoUpdatePerson", sender: nil)
  
        }

        // Customize the action buttons
        updateAction.title = NSLocalizedString("Update", comment: "MainPersonDataViewController leadingSwipeActionsConfigurationForRowAt")

        updateAction.image = #imageLiteral(resourceName: "update-35")
        updateAction.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)

        let swipeConfiguration = UISwipeActionsConfiguration(actions: [updateAction])

        return swipeConfiguration
    }

    func ReadPersonsFiredata(search: Bool, searchValue: String) {
        
        var personsRef: DatabaseReference!
        var personsRef1 : DatabaseReference!
        
        if search {
            personsRef1 = Database.database().reference().child("person")
            personsRef =  (personsRef1.queryOrdered(byChild: "personData/name").queryEqual(toValue: searchValue) as! DatabaseReference)
        } else {
            personsRef = Database.database().reference().child("person")
        }
        
        personsRef.observe(.value, with: { snapshot in

            var tempPersons = [Person]()
            for child in snapshot.children {

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
                    let gender = personData["gender"] as? Int,

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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 'prepare' will run after every segue.
        
        if segue.identifier! == "gotoUpdatePerson" {
            
            // Find the indexPath.row for the cell which is selected
            if let indexPath = tableView.indexPathForSelectedRow {
                let vc = segue.destination as! PersonViewController
                vc.PersonNameText = persons[indexPath.row].personData.name
                vc.PersonAddressText = persons[indexPath.row].personData.address
                vc.PersonDateOfBirthText = persons[indexPath.row].personData.dateOfBirth
                vc.PersonGenderInt = persons[indexPath.row].personData.gender
                vc.PersonIdText = persons[indexPath.row].id
                vc.PersonOption = 1         // Update == 1
                vc.PersonTitle = NSLocalizedString("Update Person", comment: "MainPersonDataViewController.swift prepare")
            } else {
            
                // indexRowUpdateSwipe is initiated at leadingSwipeActionsConfigurationForRowAt's "Update'
                
                let vc = segue.destination as! PersonViewController
                vc.PersonNameText = persons[indexRowUpdateSwipe].personData.name
                vc.PersonAddressText = persons[indexRowUpdateSwipe].personData.address
                vc.PersonDateOfBirthText = persons[indexRowUpdateSwipe].personData.dateOfBirth
                vc.PersonGenderInt = persons[indexRowUpdateSwipe].personData.gender
                vc.PersonIdText = persons[indexRowUpdateSwipe].id
                vc.PersonOption = 1         // Update == 1
                vc.PersonTitle = NSLocalizedString("Update Person", comment: "MainPersonDataViewController.swift prepare")
                
            }
            
        } else if segue.identifier! == "gotoAddPerson" {
            let vc = segue.destination as! PersonViewController
            vc.PersonNameText = ""
            vc.PersonAddressText = ""
            vc.PersonDateOfBirthText = ""
            vc.PersonGenderInt = 0
            vc.PersonIdText = ""
            vc.PersonOption = 0             // Save new person == 0
            vc.PersonTitle = NSLocalizedString("New Person", comment: "MainPersonDataViewController.swift prepare")
        
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        // Remove observers
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
}
