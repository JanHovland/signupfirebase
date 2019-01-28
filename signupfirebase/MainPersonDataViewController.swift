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
 ".indexOn" : ["personData/firstName", "personData/lastName", "personData/address"]
 }
 }
 }
 
*/

// Global variables
var globalPersonAddressText =  ""
var globalPersonDateOfBirthText = ""
var globalPersonFirstNameText = ""
var globalPersonGenderInt = -1
var globalPersonLastNameText = ""
var globalPersonPhoneNumberText = ""

class MainPersonDataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate  {
    
    @IBOutlet var tableView: UITableView!

    @IBOutlet weak var searchBarPerson: UISearchBar!
    
    var persons = [Person]()
    var activeField: UITextField!
    
    var indexRowUpdateSwipe  = -1

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        searchBarPerson.delegate = self
        
        ReadPersonsFiredata(search: false, searchValue: "")
        
        tableView.reloadData()
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

        // If you change a label in a viewCell, check Main.storyboard and delete the old value of the label
        cell.firstNameLabel?.text = persons[indexPath.row].personData.firstName
        cell.lastNameLabel?.text = persons[indexPath.row].personData.lastName
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
        
        var db: DatabaseReference!
        var personsRef: DatabaseQuery!
        
        db = Database.database().reference().child("person")
        
        if search {
            personsRef =  db.queryOrdered(byChild: "personData/firstName").queryEqual(toValue: searchValue)
        } else {
            personsRef =  db
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
                    let address = personData["address"] as? String,
                    let city = personData["city"] as? String,
                    let dateOfBirth = personData["dateOfBirth"] as? String,
                    let firstName = personData["firstName"] as? String,
                    let gender = personData["gender"] as? Int,
                    let lastName = personData["lastName"] as? String,
                    let phoneNumber = personData["phoneNumber"] as? String,
                    let postalCodeNumber = personData["postalCodeNumber"] as? String,
                    let timestamp = dict["timestamp"] as? Double {
                    let author = Author(uid: uid,
                                        username: username,
                                        email: email)

                    let personData = PersonData(address: address,
                                                city : city,
                                                dateOfBirth: dateOfBirth,
                                                firstName: firstName,
                                                gender: gender,
                                                lastName: lastName,
                                                phoneNumber : phoneNumber,
                                                postalCodeNumber : postalCodeNumber)

                    let person = Person(id: childSnapshot.key,
                                        author: author,
                                        personData: personData,
                                        timestamp: timestamp)

                    tempPersons.append(person)

                }
            }

            // Update the posts array
            self.persons = tempPersons
            
            // Sorting the persons array on firstName
            self.persons.sort(by: {$0.personData.firstName < $1.personData.firstName})
            
            // Fill the table view
            self.tableView.reloadData()

        })
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 'prepare' will run after every segue.
        if segue.identifier! == "gotoUpdatePerson" {
            
            // Resetter globale variabler
            globalPersonAddressText =  ""
            globalPersonDateOfBirthText = ""
            globalPersonFirstNameText = ""
            globalPersonGenderInt = -1
            globalPersonLastNameText = ""
            globalPersonPhoneNumberText = ""
            
            // Find the indexPath.row for the cell which is selected
            if let indexPath = tableView.indexPathForSelectedRow {
                let vc = segue.destination as! PersonViewController
                vc.PersonIdText = persons[indexPath.row].id
                vc.PersonAddressText = persons[indexPath.row].personData.address
                vc.PersonCityText = persons[indexPath.row].personData.city
                vc.PersonDateOfBirthText = persons[indexPath.row].personData.dateOfBirth
                vc.PersonFirstNameText = persons[indexPath.row].personData.firstName
                vc.PersonGenderInt = persons[indexPath.row].personData.gender
                vc.PersonLastNameText = persons[indexPath.row].personData.lastName
                vc.PersonPhoneNumberText = persons[indexPath.row].personData.phoneNumber
                vc.PersonPostalCodeNumberText = persons[indexPath.row].personData.postalCodeNumber
                
                vc.PersonOption = 1         // Update == 1
                vc.PersonTitle = NSLocalizedString("Update Person", comment: "MainPersonDataViewController.swift prepare")
            } else {
            
                // indexRowUpdateSwipe is initiated at leadingSwipeActionsConfigurationForRowAt's "Update'
                
                let vc = segue.destination as! PersonViewController
                vc.PersonIdText = persons[indexRowUpdateSwipe].id
                vc.PersonAddressText = persons[indexRowUpdateSwipe].personData.address
                vc.PersonCityText = persons[indexRowUpdateSwipe].personData.city
                vc.PersonDateOfBirthText = persons[indexRowUpdateSwipe].personData.dateOfBirth
                vc.PersonFirstNameText = persons[indexRowUpdateSwipe].personData.firstName
                vc.PersonGenderInt = persons[indexRowUpdateSwipe].personData.gender
                vc.PersonLastNameText = persons[indexRowUpdateSwipe].personData.lastName
                vc.PersonPhoneNumberText = persons[indexRowUpdateSwipe].personData.phoneNumber
                vc.PersonPostalCodeNumberText = persons[indexRowUpdateSwipe].personData.postalCodeNumber

                vc.PersonOption = 1         // Update == 1
                vc.PersonTitle = NSLocalizedString("Update Person", comment: "MainPersonDataViewController.swift prepare")
                
            }
            
        } else if segue.identifier! == "gotoAddPerson" {
            let vc = segue.destination as! PersonViewController
            vc.PersonIdText = ""
            vc.PersonAddressText = ""
            vc.PersonCityText  = ""
            vc.PersonDateOfBirthText = ""
            vc.PersonFirstNameText = ""
            vc.PersonGenderInt = 0
            vc.PersonLastNameText = ""
            vc.PersonPhoneNumberText = ""
            vc.PersonPostalCodeNumberText = ""
                
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
    
    // Get the persons for the query from Firebase
    // Uses the search button in the online keyboard
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Get the persons for the query from Firebase
        if searchBarPerson.text!.count > 0 {
            ReadPersonsFiredata(search: true, searchValue: searchBarPerson.text!)
        } else {
            ReadPersonsFiredata(search: false, searchValue: "")
        }
            
        searchBarPerson.endEditing(true)

    }
   
}
