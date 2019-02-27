//
//  MainPersonDataTableViewController.swift
//  signupfirebase
//
//  Created by Jan  on 23/12/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import Firebase        
import UIKit
import MessageUI

/*

 Firebase rules:

 {
 "rules": {
 "person": {
 ".read": "auth.uid != null",
 ".write": "auth.uid != null",
 ".indexOn" : ["personData/firstName", "personData/lastName", "personData/address"]
 },
 
 "postnr": {
 ".read": "auth.uid != null",
 ".write": "auth.uid != null",
 }
 }
 }
 
*/

// Global variables
var globalPersonAddressText =  ""
var globalPersonDateOfBirthText = ""
var globalPersonNameText = ""
var globalPersonGenderInt = -1
var globalPersonPhoneNumberText = ""

class MainPersonDataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var searchBarPerson: UISearchBar!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    var phoneNumberInput = ""
    
    var persons = [Person]()
    
    var searchedPersons = [Person]()
    var searching = false
    
    var activeField: UITextField!
    
    var indexRowUpdateSwipe  = -1

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        searchBarPerson.delegate = self
        
        // Forces the online keyboard to be lowercased
        searchBarPerson.autocapitalizationType = UITextAutocapitalizationType.none
    
        activity.style = .gray
        activity.isHidden = false
        
   }

    override func viewDidAppear(_ animated: Bool) {
        activity.startAnimating()
        
        // Get the posts from Firebase
        ReadPersonsFiredata()
        
        activity.isHidden = true
        activity.stopAnimating()
        
        // It is necessary to reloadData to syncronize correctly
        self.tableView.reloadData()
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searching {
            return searchedPersons.count
        } else {
            return persons.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var x: Float64 = 3.75
        var y: Float64 = 7.0
        
        var fontSize: Float64 = 9.0
        var text = ""
        
        var name = ""
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PersonDataTableViewCell

        // If you change a label in a viewCell, check Main.storyboard and delete the old value of the label
        // When I deleted firstNameLabel, it was still in Main.storyboard:
        // <outlet property="firstNameLabel" destination="bfO-dL-I5s" id="BBZ-st-hNm"/>
        
        // Configure the cell
        if searching {
            let name1 = searchedPersons[indexPath.row].personData.name.lowercased()
            name = name1.capitalized
            cell.nameLabel?.text = name
            cell.bornLabel?.text = searchedPersons[indexPath.row].personData.dateOfBirth
            cell.addressLabel?.text = searchedPersons[indexPath.row].personData.address + " " +
                                      searchedPersons[indexPath.row].personData.postalCodeNumber + " " +
                                      searchedPersons[indexPath.row].personData.city
        } else {
            let name1 = persons[indexPath.row].personData.name.lowercased()
            name = name1.capitalized
            cell.bornLabel?.text = persons[indexPath.row].personData.dateOfBirth
            cell.nameLabel?.text = name
            cell.addressLabel?.text = persons[indexPath.row].personData.address + " " +
                                      persons[indexPath.row].personData.postalCodeNumber + " " +
                                      persons[indexPath.row].personData.city
            
            if let url = URL(string: persons[indexPath.row].personData.imageFileURL) {
                
                let findCellImage = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                    
                    guard let imageData = data else {
                        return
                    }
                    
                    OperationQueue.main.addOperation {
                        guard let image = UIImage(data: imageData) else {
                            return
                        }
                        
                        cell.imageLabel.image = image
                        
                    }
                    
                })
                
                findCellImage.resume()
                
            }
            
        }
        
        
        // Find all Uppercase letters of the name
        text = findFirstLettersOfName(name: name)
        
        if text.count == 1 {
            x = x + 5.50
        } else if text.count == 2 {
            x = x + 2.75
        } else if text.count == 3 {
            
        } else if text.count == 4 {
            x = x - 1
            y = y + 2
            fontSize = 7.0
        } else {
            x = x - 1
            y = y + 2
            fontSize = 6.0
            
            // Set a new value to rexr
            text = String(text.prefix(4)) + ".."
            
        }
        
        cell.imageLabel?.image = textToImage(drawText: text,
                                             size:  fontSize,
                                             inImage: UIImage(named: "circle-25.png")!,
                                             atPoint: CGPoint(x: x, y: y))
        
        return cell
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
       if searchText.count > 0 {
        searchedPersons = persons.filter({$0.personData.name.contains(searchText.uppercased())})
           searching = true
       } else {
           searching = false
       }

       // Fill the table view
       self.tableView.reloadData()
        
    }
    
    // called when keyboard done button pressed
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBarPerson.endEditing(true)
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

    func ReadPersonsFiredata() {
        
        var db: DatabaseReference!
        
        db = Database.database().reference().child("person")
        
        db.observe(.value, with: { snapshot in
            
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
                    let name = personData["name"] as? String,
                    let gender = personData["gender"] as? Int,
                    let phoneNumber = personData["phoneNumber"] as? String,
                    let postalCodeNumber = personData["postalCodeNumber"] as? String,
                    let municipality = personData["municipality"] as? String,
                    let municipalityNumber = personData["municipalityNumber"] as? String,
                    let imageFileURL = personData["imageFileURL"] as? String,
                    let timestamp = dict["timestamp"] as? Double {
                    
                    let author = Author(uid: uid,
                                        username: username,
                                        email: email)
                    
                    let personData = PersonData(address: address,
                                                city : city,
                                                dateOfBirth: dateOfBirth,
                                                name: name,
                                                gender: gender,
                                                phoneNumber : phoneNumber,
                                                postalCodeNumber : postalCodeNumber,
                                                municipality: municipality,
                                                municipalityNumber: municipalityNumber,
                                                imageFileURL: imageFileURL)
                    
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
            self.persons.sort(by: {$0.personData.name < $1.personData.name})
            
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
            globalPersonNameText = ""
            globalPersonGenderInt = -1
            globalPersonPhoneNumberText = ""
            globalMunicipality = ""
            globalMunicipalityNumber = ""
            
            // Find the indexPath.row for the cell which is selected
            if let indexPath = tableView.indexPathForSelectedRow {
                let vc = segue.destination as! PersonViewController
                vc.PersonIdText = persons[indexPath.row].id
                vc.PersonAddressText = persons[indexPath.row].personData.address
                vc.PersonCityText = persons[indexPath.row].personData.city
                vc.PersonDateOfBirthText = persons[indexPath.row].personData.dateOfBirth
                
                let name1 = persons[indexPath.row].personData.name.lowercased()
                let name = name1.capitalized
                
                vc.PersonNameText = name
                vc.PersonGenderInt = persons[indexPath.row].personData.gender
                vc.PersonPhoneNumberText = persons[indexPath.row].personData.phoneNumber
                vc.PersonPostalCodeNumberText = persons[indexPath.row].personData.postalCodeNumber
                
                vc.PersonMunicipalityText = persons[indexPath.row].personData.municipality
                vc.PersonMunicipalityNumberText = persons[indexPath.row].personData.municipalityNumber
                
                vc.PersonOption = 1         // Update == 1
                vc.PersonTitle = NSLocalizedString("Update Person", comment: "MainPersonDataViewController.swift prepare")
            } else {
            
                // indexRowUpdateSwipe is initiated at leadingSwipeActionsConfigurationForRowAt's "Update'
                
                let vc = segue.destination as! PersonViewController
                vc.PersonIdText = persons[indexRowUpdateSwipe].id
                vc.PersonAddressText = persons[indexRowUpdateSwipe].personData.address
                vc.PersonCityText = persons[indexRowUpdateSwipe].personData.city
                vc.PersonDateOfBirthText = persons[indexRowUpdateSwipe].personData.dateOfBirth
                
                let name1 = persons[indexRowUpdateSwipe].personData.name.lowercased()
                let name = name1.capitalized
                
                vc.PersonNameText = name
                vc.PersonGenderInt = persons[indexRowUpdateSwipe].personData.gender
                vc.PersonPhoneNumberText = persons[indexRowUpdateSwipe].personData.phoneNumber
                vc.PersonPostalCodeNumberText = persons[indexRowUpdateSwipe].personData.postalCodeNumber

                vc.PersonMunicipalityText = persons[indexRowUpdateSwipe].personData.municipality
                vc.PersonMunicipalityNumberText = persons[indexRowUpdateSwipe].personData.municipalityNumber
                
                vc.PersonOption = 1         // Update == 1
                vc.PersonTitle = NSLocalizedString("Update Person", comment: "MainPersonDataViewController.swift prepare")
                
            }
            
        } else if segue.identifier! == "gotoAddPerson" {
            let vc = segue.destination as! PersonViewController
            vc.PersonIdText = ""
            vc.PersonAddressText = ""
            vc.PersonCityText  = ""
            vc.PersonDateOfBirthText = ""
            vc.PersonNameText = ""
            vc.PersonGenderInt = 0
            vc.PersonPhoneNumberText = ""
            vc.PersonPostalCodeNumberText = ""
 
            vc.PersonMunicipalityText = ""
            vc.PersonMunicipalityNumberText = ""
            
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
    
    // Make a call wuth the phone number
    @IBAction func buttonPhone(_ sender: UIButton) {
        
        // Find the row of the selected cell
        let buttonPostion = sender.convert(sender.bounds.origin, to: tableView)
        if let indexPath = tableView.indexPathForRow(at: buttonPostion) {
            let rowIndex =  indexPath.row
            phoneNumberInput = persons[rowIndex].personData.phoneNumber
        }
        
        phoneNumberInput = phoneNumberInput.replacingOccurrences(of: " ", with: "")

        if  let url : URL = URL(string: "tel://\(phoneNumberInput)"){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    // Send a message with the phone number
    @IBAction func buttonMessage(_ sender: UIButton) {
        
        if MFMessageComposeViewController.canSendText() {
            
            // Find the row of the selected cell
            let buttonPostion = sender.convert(sender.bounds.origin, to: tableView)
            if let indexPath = tableView.indexPathForRow(at: buttonPostion) {
                let rowIndex =  indexPath.row
                phoneNumberInput = persons[rowIndex].personData.phoneNumber
            }

            phoneNumberInput = phoneNumberInput.replacingOccurrences(of: " ", with: "")
            
            let controller = MFMessageComposeViewController()
            controller.body = "Test sending av SMS"
            controller.recipients = [self.phoneNumberInput]
            controller.messageComposeDelegate = self as? MFMessageComposeViewControllerDelegate
            
            self.present(controller, animated: true, completion: nil)
            
        } else {
            let melding = "\r\n" + NSLocalizedString("Cannot send message", comment: "MainPersonDataViewController.swift buttonMessage")
            self.presentAlert(withTitle: NSLocalizedString("Error",
                                                           comment: "MainPersonDataViewController.swift buttonMessage"),
                              message: melding)
        }
    }
    
}

extension ViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
