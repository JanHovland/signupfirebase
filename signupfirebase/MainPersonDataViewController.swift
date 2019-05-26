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

var selectedName: String = ""

var persons = [Person]()

// Variable for "indexed table view"
var personDataDictionary = [String: [PersonData]]()
var personDataSectionTitles = [String]()


class MainPersonDataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var searchBarPerson: UISearchBar!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    var phoneNumberInput = ""
    
    var personName = ""
    var personFirstName = ""
    var personAddress = ""
    var locationOnMap = ""
    var personEmail = ""
    
    var searching = false
    private var currentPerson: Person?

    var searchedPersons = [Person]()
    
    var activeField: UITextField!
    
    var indexRowUpdateSwipe  = -1
    
    // Called after the view has been loaded. For view controllers created in code, this is after -loadView. For view controllers unarchived from a nib, this is after the view is set.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBarPerson.delegate = self
        
        // Forces the online keyboard to be lowercased
        searchBarPerson.autocapitalizationType = UITextAutocapitalizationType.none
 
        // let start = Date()
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.FindSearchedPersonData(searchText: "")
        }
        
        // let end = Date()
        // print("Elapsed time MainPersonDataViewController = \(end.timeIntervalSince(start))")
        
        activity.style = .gray
        activity.isHidden = true
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        self.tableView.refreshControl = refreshControl

        activity.style = .gray
        activity.isHidden = true
 
    }

    @objc func reloadData() {
        persons = [Person]()
        DispatchQueue.main.async {
            self.makeReadPersons()
            self.FindSearchedPersonData(searchText: "")
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    // Called when the view is about to made visible. Default does nothing
    override func viewWillAppear(_ animated: Bool) {
        // On return from "MessageViewController" navigationbar shows "< Persondata"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        self.navigationItem.hidesBackButton = true
        
        // Resets the two globals that is used in PersonsService.swift in function storePersonFiredata()
        
        newPersonCounter = -1
        dbKey = ""

        // Reloads everything from scratch. Redisplays visible rows. Note that this will cause any existing drop placeholder rows to be removed.
        self.tableView.reloadData()
        
    }
    
    // Called when the view has been fully transitioned onto the screen. Default does nothing
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    // Asks the data source to return the number of sections in the table view.
    func numberOfSections(in tableView: UITableView) -> Int {
        return personDataSectionTitles.count
    }

    // Asks the data source to return the number of sections in the table view.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let key = personDataSectionTitles[section]
        
        if let personValues = personDataDictionary[key] {
            return personValues.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! PersonDataTableViewCell
        
        selectedName = String(cell.nameLabel!.text!)
        performSegue(withIdentifier: "gotoUpdatePerson", sender: self)
    }
    
    // Asks the data source for a cell to insert in a particular location of the table view.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var imageFileURL = ""
        
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PersonDataTableViewCell

        // If you change a label in a viewCell, check Main.storyboard and delete the old value of the label
        // When I deleted firstNameLabel, it was still in Main.storyboard:
        // <outlet property="firstNameLabel" destination="bfO-dL-I5s" id="BBZ-st-hNm"/>
        
        // There is now no selectionStyle of the selected cell (.default, .blue, .gray or ,none)
        cell.selectionStyle = .none
        
        let key = personDataSectionTitles[indexPath.section]
        
        // print("key = \(key as Any)")
        
        if let personDataValues = personDataDictionary[key] {
            
            print("indexPath.row = \(indexPath.row)")

            let name1 = personDataValues[indexPath.row].name.lowercased()
            
            // print(name1 as Any)
            
            let name = name1.capitalized
            cell.nameLabel.text = name
            
            cell.bornLabel?.text = personDataValues[indexPath.row].dateOfBirth1
            
            cell.addressLabel?.text = personDataValues[indexPath.row].address + " " +
                personDataValues[indexPath.row].postalCodeNumber + " " +
                personDataValues[indexPath.row].city
            
            imageFileURL = personDataValues[indexPath.row].photoURL
            
            if let image = CacheManager.shared.getFromCache(key: imageFileURL) as? UIImage {
                cell.imageLabel?.image = image
                imageFileURL = ""
            } else if let url = URL(string: imageFileURL) {
                let findCellImage = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                    guard let imageData = data else {
                       return
                    }
                    OperationQueue.main.addOperation {
                        guard let image = UIImage(data: imageData) else {
                            return
                        }
                        
                        cell.imageLabel?.image = image
                        
                        // Add the downloaded image to cache
                        CacheManager.shared.cache(object: image, key: imageFileURL)
                        imageFileURL = ""
                        
                    }
                })
                
                findCellImage.resume()
                
            }
        }
        
        return cell
    }
    
    // Asks the data source for the title of the header of the specified section of the table view.
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        print("section = \(personDataSectionTitles[section].count as Any)")
        
        // self.makeReadPersons()
        
        return personDataSectionTitles[section]
    }
    
    // Asks the data source to return the titles for the sections for a table view.
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return personDataSectionTitles
    }
    
    // Tells the delegate that the user changed the search text.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       
        if searchText.count > 0 {
            searching = true
        } else {
            searching = false
        }
        
        // Search
        FindSearchedPersonData(searchText: searchText)
        
    }
    
    // called when keyboard done button pressed
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBarPerson.endEditing(true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

       // In order to show both the icon and the text, the height of the tableViewCell must be > 91
       let deleteAction = UIContextualAction(style: .destructive, title: "") {
            (action, sourceView, completionHandler) in
        
            // persons.remove(at: [indexPath.section][indexPath.row])

            let cell = tableView.cellForRow(at: indexPath) as! PersonDataTableViewCell
            selectedName = String(cell.nameLabel!.text!)

            let value = self.findPersonData(inputName: selectedName)

            // Find the id of the post
            let id = value.id

            let dataBase = Database.database().reference().child("person" + "/" + id)

            dataBase.setValue(nil)

            // remove(persons[indexPath.row].personData.          // remove(persons[indexPath.row].personData.firstName)
        
            persons.remove(at: indexPath.row)
        
        
            // let key = personDataSectionTitles[indexPath.section]
            // let personDataValues = personDataDictionary[key]
        
        
            // Works when there is only one person at at section
        
            personDataSectionTitles.remove(at: indexPath.section)
        
        
            // let key1 = personDataSectionTitles[indexPath.section]
            // let personDataValues = personDataDictionary[key1]
        
        
        
        
//   VIRKER IKKE !!!!!     let indexPath = IndexPath(row: indexPath.row, section: indexPath.section)                      // (item: 0, section: 0)
//        tableView.deleteRows(at: [indexPath], with: .fade)
        

        
//            let key = personDataSectionTitles[indexPath.section]
//            print("key fra trailing = \(key as Any)")
//            print("firstName from trailing = \(value.firstName as Any)")
//
//            // Find number of persons in section
//            let  y = personDataDictionary[key]?.count
//            print("Antall personer i seksjonen = \(y! as Any)")
//
//
//        print("test")
            // personDataSectionTitles[0].remove(at: indexPath.row)

            // personDataSectionTitles[indexPath.section].remove(at: indexPath.section)

            // print(personDataSectionTitles[indexPath.section] as Any)

            // self.performSegue(withIdentifier: "goBackToLogin", sender: self)

            self.tableView.reloadData()
        
        // self.makeReadPersons()
        

        }

        // Customize the action buttons
        deleteAction.title = NSLocalizedString("Delete", comment: "MainPersonDataViewController trailingSwipeActionsConfigurationForRowAt")

        deleteAction.image = #imageLiteral(resourceName: "trash-35")
        deleteAction.backgroundColor = .red

        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])

        return swipeConfiguration
    }

      // Altenative to "trailingSwipeActionsConfigurationForRowAt"
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == UITableViewCell.EditingStyle.delete {
//
//            let cell = tableView.cellForRow(at: indexPath) as! PersonDataTableViewCell
//            selectedName = String(cell.nameLabel!.text!)
//
//            let value = self.findPersonData(inputName: selectedName)
//
//            // Find the id of the post
//            let id = value.id
//
//            let dataBase = Database.database().reference().child("person" + "/" + id)
//
//            dataBase.removeValue()
//
//            performSegue(withIdentifier: "goBackToLogin", sender: self)
//
//        }
//    }
  
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            persons.remove(at: [indexPath.section][indexPath.row])
//
//            let cell = tableView.cellForRow(at: indexPath) as! PersonDataTableViewCell
//            selectedName = String(cell.nameLabel!.text!)
//
//            let value = findPersonData(inputName: selectedName)
//
//            // Find the id of the post
//            let id = value.id
//
//            let dataBase = Database.database().reference().child("person" + "/" + id)
//
//            dataBase.removeValue()
//
//
//
//            let key = personDataSectionTitles[indexPath.section]
//
//            if let personDataValues = personDataDictionary[key] {
//
//                let name1 = personDataValues[indexPath.row].name.lowercased()
//
//
//
//            // persons.removeAtIndex(indexPath.section - 1)
//
//            // let indexSet = IndexSet(integer: indexPath.section)
//            // tableView.deleteSections(indexSet, with: .automatic)
//
//
//            //            var dict = persons[indexPath.section]
//            //            let key = personDataSectionTitles[indexPath.section]
//            //            let codes = dict[key]
//            //
//            //            //remove code from [Code]
//            //            codes.remove(at: indexPath.row)
//            //            dict[key] = codes
//            //            persons[indexPath.section] = dict
//            //            userDefaults.setValue(NSKeyedArchiver.archivedData(withRootObject: codeArray), forKey: "codeArrayKey")
//            //            UserDefaults.synchronize()
//
//            // self.tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .fade)
//
//
//
//
//        }
//    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // In order to show both the icon and the text, the height of the tableViewCell must be > 91
        let updateAction = UIContextualAction(style: .normal, title: "") {
            (action, sourceView, completionHandler) in
            
            let cell = tableView.cellForRow(at: indexPath) as! PersonDataTableViewCell
            selectedName = String(cell.nameLabel!.text!)
            
            self.performSegue(withIdentifier: "gotoUpdatePerson", sender: nil)
  
        }

        // Customize the action buttons
        updateAction.title = NSLocalizedString("Update", comment: "MainPersonDataViewController leadingSwipeActionsConfigurationForRowAt")

        updateAction.image = #imageLiteral(resourceName: "update-35")
        updateAction.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)

        let swipeConfiguration = UISwipeActionsConfiguration(actions: [updateAction])

        return swipeConfiguration
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 
        // Find the data for thw chosen person = selectedName
        let value = findPersonData(inputName: selectedName)
        
        // 'prepare' will run after every segue.
        if segue.identifier! == "gotoUpdatePerson" {

            // Find the viewController
            let vc = segue.destination as! PersonViewController
            
            vc.PersonAddressText = value.address
            vc.PersonCityText = value.city
            vc.PersonDateOfBirthText1 = value.dateOfBirth1
            vc.PersonDateOfBirthText2 = value.dateOfBirth2
            vc.PersonFirstNameText = value.firstName
            vc.PersonGenderInt = value.gender
            vc.PersonIdText = value.id
            vc.PersonLastNameText = value.lastName
            vc.PersonMunicipalityNumberText = value.municipalityNumber
            vc.PersonMunicipalityText = value.municipality
            vc.PersonOption = 1         // Update == 1
            vc.PersonPersonEmailText = value.personEmail
            vc.PersonPhoneNumberText = value.phoneNumber
            vc.PersonPhotoURL = value.photoURL
            vc.PersonPostalCodeNumberText = value.postalCodeNumber
            vc.PersonTitle = NSLocalizedString("Update Person", comment: "MainPersonDataViewController.swift prepare")

            
            // Initialize the globals
            globalAddress = value.address
            globalCity = value.city
            globalCityCodeNumber = value.postalCodeNumber
            globalDateOfBirth = value.dateOfBirth1
            globalFirstName = value.firstName
            globalGender = value.gender
            globalLastName = value.lastName
            globalMunicipalityNumber = value.municipalityNumber
            globalMunicipality = value.municipality
            globalPersonEmail = value.personEmail
            globalPhoneNumber = value.phoneNumber
       
        } else if segue.identifier! == "gotoAddPerson" {
            
            let vc = segue.destination as! PersonViewController

            vc.PersonAddressText = "" 
            vc.PersonCityText  = ""
            vc.PersonDateOfBirthText1 = ""
            vc.PersonDateOfBirthText2 = ""
            vc.PersonFirstNameText = ""
            vc.PersonGenderInt = 0
            vc.PersonIdText = ""
            vc.PersonLastNameText = ""
            vc.PersonMunicipalityText = ""
            vc.PersonMunicipalityNumberText = ""
            vc.PersonOption = 0             // Save new person == 0
            vc.PersonPhoneNumberText = ""
            vc.PersonPostalCodeNumberText = ""
            vc.PersonPhotoURL = ""
            vc.PersonPersonEmailText = ""
            vc.PersonTitle = NSLocalizedString("New Person", comment: "MainPersonDataViewController.swift prepare")
        
            // Reset all globala
            globalAddress = ""
            globalCity = ""
            globalCityCodeNumber = ""
            globalDateOfBirth = ""
            globalFirstName = ""
            globalGender = 0
            globalLastName = ""
            globalMunicipalityNumber = ""
            globalMunicipality = ""
            globalPersonEmail = ""
            globalPhoneNumber = ""
            
        } else if segue.identifier! == "gotoMap" {
        
            let vc = segue.destination as! MapViewController
            
            vc.titleMap = personName
            vc.locationOnMap = locationOnMap
            vc.address = personAddress
            
            vc.changeName = ""
            vc.changeLatitude = 0.0
            vc.changeLlongitude = 0.0
            
            if value.firstName == "Johanne Kristine", value.lastName == "Lima" {
                vc.changeName = "JKR"
                vc.changeLatitude = 60.429350
                vc.changeLlongitude = 9.465658
            }
            
        } else if segue.identifier! == "gotoMessage" {
            
            let vc = segue.destination as! MessageViewController
            
            vc.messageBody = "Gratulerer så mye med fødselsdagen " + personFirstName + " 😄"
            vc.messagePhoneNumber = phoneNumberInput
            vc.messageId = "fromMainPersonData"
        
        } else if segue.identifier! == "gotoEmail" {
            
            let vc = segue.destination as! EpostViewController
            
            vc.mailRecipients = personEmail
            vc.mailSubject = ""
            vc.mailMessageBody = ""
        
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Remove observers
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    // Connect to the Map
    @IBAction func mapButton(_ sender: UIButton) {
        
        // Find the row of the selected cell
        let buttonPosition = sender.convert(sender.bounds.origin, to: tableView)
        if let indexPath = tableView.indexPathForRow(at: buttonPosition) {
            tableView.deselectRow(at: indexPath, animated: true)
            let cell = tableView.cellForRow(at: indexPath) as! PersonDataTableViewCell
            selectedName = String(cell.nameLabel!.text!)
            let value = self.findPersonData(inputName: selectedName)
            phoneNumberInput = value.phoneNumber
            
            personName = value.name.lowercased()
            personName = personName.capitalized
            
            locationOnMap = value.address + " " +
                            value.postalCodeNumber + " " +
                            value.city
            
            personAddress = value.address
        }
      
    }
    
    // Make a call wuth the phone number
    @IBAction func buttonPhone(_ sender: UIButton) {
        
        // Find the row of the selected cell
        let buttonPosition = sender.convert(sender.bounds.origin, to: tableView)
        if let indexPath = tableView.indexPathForRow(at: buttonPosition) {
            tableView.deselectRow(at: indexPath, animated: true)
            let cell = tableView.cellForRow(at: indexPath) as! PersonDataTableViewCell
            selectedName = String(cell.nameLabel!.text!)
            let value = self.findPersonData(inputName: selectedName)
            phoneNumberInput = value.phoneNumber
        }
 
        phoneNumberInput = phoneNumberInput.replacingOccurrences(of: " ", with: "")

        if  let url : URL = URL(string: "tel://\(phoneNumberInput)"){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    // Send a message with the phone number
    @IBAction func buttonMessage(_ sender: UIButton) {
        
        // Find the row of the selected cell
        let buttonPosition = sender.convert(sender.bounds.origin, to: tableView)
        if let indexPath = tableView.indexPathForRow(at: buttonPosition) {
            tableView.deselectRow(at: indexPath, animated: true)
            let cell = tableView.cellForRow(at: indexPath) as! PersonDataTableViewCell
            selectedName = String(cell.nameLabel!.text!)
            let value = self.findPersonData(inputName: selectedName)
            phoneNumberInput = value.phoneNumber
            
            personFirstName = value.firstName.lowercased()
            personFirstName = personFirstName.capitalized
        }
   
    }
    
    @IBAction func buttonEmail(_ sender: UIButton) {
    
        // Find the row of the selected cell
        let buttonPosition = sender.convert(sender.bounds.origin, to: tableView)
        if let indexPath = tableView.indexPathForRow(at: buttonPosition) {
            tableView.deselectRow(at: indexPath, animated: true)
            let cell = tableView.cellForRow(at: indexPath) as! PersonDataTableViewCell
            selectedName = String(cell.nameLabel!.text!)
            let value = self.findPersonData(inputName: selectedName)
            personEmail = value.personEmail
        }
    }
 
    // Find personlData. Returns address, city, dateOfBirth, name, gender, phoneNumber, postalCodeNumber, municipality, municipalityNumber, photoURL
    func findPersonData(inputName: String) -> (id: String,
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
        photoURL: String,
        firstName: String,
        lastName: String,
        personEmail: String) {
            
            // Find number of persons
            let numberOfPersons = persons.count
            
            if numberOfPersons > 0 {
                
                var idx = 0
                var personIndex = -1
                
                // Find the selected person
                repeat {
                    if persons[idx].personData.name.uppercased() == inputName.uppercased() {
                        personIndex = idx
                        idx = numberOfPersons
                    }
                    idx += 1
                } while (idx < numberOfPersons)
                
                if personIndex >= 0 {
                    
                    let id = String(persons[personIndex].id)
                    let address = String(persons[personIndex].personData.address)
                    let city = String(persons[personIndex].personData.city)
                    let dateOfBirth1 = String(persons[personIndex].personData.dateOfBirth1)
                    let dateOfBirth2 = String(persons[personIndex].personData.dateOfBirth2)
                    let name1 = String(persons[personIndex].personData.name).lowercased()
                    let name = name1.capitalized
                    let gender = persons[personIndex].personData.gender
                    let phoneNumber = String(persons[personIndex].personData.phoneNumber)
                    let postalCodeNumber = String(persons[personIndex].personData.postalCodeNumber)
                    let municipality = String(persons[personIndex].personData.municipality)
                    let municipalityNumber = String(persons[personIndex].personData.municipalityNumber)
                    let photoURL = String(persons[personIndex].personData.photoURL)
                    let firstName = String(persons[personIndex].personData.firstName)
                    let lastName = String(persons[personIndex].personData.lastName)
                    let personEmail = String(persons[personIndex].personData.personEmail)
                    
                    return (id,
                            address,
                            city,
                            dateOfBirth1,
                            dateOfBirth2,
                            name,
                            gender,
                            phoneNumber,
                            postalCodeNumber,
                            municipality,
                            municipalityNumber,
                            photoURL,
                            firstName,
                            lastName,
                            personEmail)
                    
                } else {
                    return ("",
                            "",
                            "",
                            "",
                            "",
                            "",
                            0,
                            "",
                            "",
                            "",
                            "",
                            "",
                            "",
                            "",
                            "")
                }
                
            } else {
                
                return ("",
                        "",
                        "",
                        "",
                        "",
                        "",
                        0,
                        "",
                        "",
                        "",
                        "",
                        "",
                        "",
                        "",
                        "")
                
            }
            
    }
    

    
    
    
}

extension UIViewController {
    
    // Reads all data outside the closure in ReadPersonsFiredata
    func makeReadPersons() {
        ReadPersonsFiredata { _ in
            self.FindSearchedPersonData(searchText: "")
        }
    }

    func ReadPersonsFiredata(completionHandler: @escaping (_ tempPersons: [Person]) -> Void) {
        
        var db: DatabaseReference!
        
        // Reset this variable so that it doesn'n show, if all personal data are deleted
        personDataSectionTitles = [""]
        
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
                    let authorPhotoURL = author["photoURL"] as? String,
                    let personData = dict["personData"] as? [String: Any],
                    let address = personData["address"] as? String,
                    let city = personData["city"] as? String,
                    let dateOfBirth1 = personData["dateOfBirth1"] as? String,
                    let dateOfBirth2 = personData["dateOfBirth2"] as? String,
                    let name = personData["name"] as? String,
                    let gender = personData["gender"] as? Int,
                    let phoneNumber = personData["phoneNumber"] as? String,
                    let postalCodeNumber = personData["postalCodeNumber"] as? String,
                    let municipality = personData["municipality"] as? String,
                    let municipalityNumber = personData["municipalityNumber"] as? String,
                    let personPhotoURL = personData["photoURL"] as? String,
                    let firstName = personData["firstName"] as? String,
                    let lastName = personData["lastName"] as? String,
                    let personEmail = personData["personEmail"] as? String,
                    let timestamp = dict["timestamp"] as? Double {
                    
                    let author = Author(uid: uid,
                                        username: username,
                                        email: email,
                                        photoURL: authorPhotoURL)
                    
                    let personData = PersonData(address: address,
                                                city : city,
                                                dateOfBirth1: dateOfBirth1,
                                                dateOfBirth2: dateOfBirth2,
                                                name: name,
                                                gender: gender,
                                                phoneNumber : phoneNumber,
                                                postalCodeNumber : postalCodeNumber,
                                                municipality: municipality,
                                                municipalityNumber: municipalityNumber,
                                                photoURL: personPhotoURL,
                                                firstName: firstName,
                                                lastName: lastName,
                                                personEmail: personEmail)
                    
                    let person = Person(id: childSnapshot.key,
                                        author: author,
                                        personData: personData,
                                        timestamp: timestamp)
                    
                    tempPersons.append(person)
                    
                }
            }
            
            // Sorting the persons array on firstName
            persons.sort(by: {$0.personData.name < $1.personData.name})
            persons = tempPersons
            
            completionHandler(tempPersons)
           
        })
        
    }

    func FindSearchedPersonData(searchText: String ) {
        // Reset poststedsDictionary
        personDataDictionary = [String: [PersonData]]()
        
        if persons.count > 0 {
            
            if searchText.count == 0 {
                let count = persons.count - 1
                
                for index in 0 ... count {
                    
                    let key = String(persons[index].personData.name.prefix(1))
                    
                    if var personDataValues = personDataDictionary[key] {
                        
                        personDataValues.append(PersonData(address: persons[index].personData.address,
                                                           city: persons[index].personData.city,
                                                           dateOfBirth1: persons[index].personData.dateOfBirth1,
                                                           dateOfBirth2: persons[index].personData.dateOfBirth2,
                                                           name: persons[index].personData.name,
                                                           gender: persons[index].personData.gender,
                                                           phoneNumber: persons[index].personData.phoneNumber,
                                                           postalCodeNumber: persons[index].personData.postalCodeNumber,
                                                           municipality: persons[index].personData.municipality,
                                                           municipalityNumber: persons[index].personData.municipalityNumber,
                                                           photoURL: persons[index].personData.photoURL,
                                                           firstName: persons[index].personData.firstName,
                                                           lastName: persons[index].personData.lastName,
                                                           personEmail: persons[index].personData.personEmail))
                        
                        personDataDictionary[key] = personDataValues
                        
                    } else {
                        
                        personDataDictionary[key] = [PersonData(address: persons[index].personData.address,
                                                                city: persons[index].personData.city,
                                                                dateOfBirth1: persons[index].personData.dateOfBirth1,
                                                                dateOfBirth2: persons[index].personData.dateOfBirth2,
                                                                name: persons[index].personData.name,
                                                                gender: persons[index].personData.gender,
                                                                phoneNumber: persons[index].personData.phoneNumber,
                                                                postalCodeNumber: persons[index].personData.postalCodeNumber,
                                                                municipality: persons[index].personData.municipality,
                                                                municipalityNumber: persons[index].personData.municipalityNumber,
                                                                photoURL: persons[index].personData.photoURL,
                                                                firstName: persons[index].personData.firstName,
                                                                lastName: persons[index].personData.lastName,
                                                                personEmail: persons[index].personData.personEmail)]
                        
                    }
                }
                
                personDataSectionTitles = [String](personDataDictionary.keys)
                
                // Must use local sorting of the poststedSectionTitles
                let region = NSLocale.current.regionCode?.lowercased() // Returns the local region
                let language = Locale(identifier: region!)
                
                let sortedPersonDataSection1 = personDataSectionTitles.sorted {
                        $0.compare($1, locale: language) == .orderedAscending
                }
                personDataSectionTitles = sortedPersonDataSection1
                
            } else {
                
                let searchedPersonData = persons.filter({ $0.personData.name.contains(searchText.uppercased()) })
                
                let count = searchedPersonData.count
                
                if count > 0 {
                    let count = searchedPersonData.count - 1
                    
                    for index in 0 ... count {
                        let key = String(searchedPersonData[index].personData.name.prefix(1))
                        
                        if var personDataValues = personDataDictionary[key] {
                            
                            personDataValues.append(PersonData(address: searchedPersonData[index].personData.address,
                                                               city: searchedPersonData[index].personData.city,
                                                               dateOfBirth1: searchedPersonData[index].personData.dateOfBirth1,
                                                               dateOfBirth2: searchedPersonData[index].personData.dateOfBirth2,
                                                               name: searchedPersonData[index].personData.name,
                                                               gender: searchedPersonData[index].personData.gender,
                                                               phoneNumber: searchedPersonData[index].personData.phoneNumber,
                                                               postalCodeNumber: searchedPersonData[index].personData.postalCodeNumber,
                                                               municipality: searchedPersonData[index].personData.municipality,
                                                               municipalityNumber: searchedPersonData[index].personData.municipalityNumber,
                                                               photoURL: searchedPersonData[index].personData.photoURL,
                                                               firstName: searchedPersonData[index].personData.firstName,
                                                               lastName: searchedPersonData[index].personData.lastName,
                                                               personEmail: searchedPersonData[index].personData.personEmail))
                            
                            personDataDictionary[key] = personDataValues
                            
                        } else {
                            
                            personDataDictionary[key] =  [PersonData(address: searchedPersonData[index].personData.address,
                                                                     city: searchedPersonData[index].personData.city,
                                                                     dateOfBirth1: searchedPersonData[index].personData.dateOfBirth1,
                                                                     dateOfBirth2: searchedPersonData[index].personData.dateOfBirth2,
                                                                     name: searchedPersonData[index].personData.name,
                                                                     gender: searchedPersonData[index].personData.gender,
                                                                     phoneNumber: searchedPersonData[index].personData.phoneNumber,
                                                                     postalCodeNumber: searchedPersonData[index].personData.postalCodeNumber,
                                                                     municipality: searchedPersonData[index].personData.municipality,
                                                                     municipalityNumber: searchedPersonData[index].personData.municipalityNumber,
                                                                     photoURL: searchedPersonData[index].personData.photoURL,
                                                                     firstName: searchedPersonData[index].personData.firstName,
                                                                     lastName: searchedPersonData[index].personData.lastName,
                                                                     personEmail: searchedPersonData[index].personData.personEmail)]
                            
                        }
                    }
                }
                
                personDataSectionTitles = [String](personDataDictionary.keys)
                
                // Must use local sorting of the poststedSectionTitles
                let region = NSLocale.current.regionCode?.lowercased() // Returns the local region
                let language = Locale(identifier: region!)
                let sortedPersonDataSection1 = personDataSectionTitles.sorted {
                    $0.compare($1, locale: language) == .orderedAscending
                }
                personDataSectionTitles = sortedPersonDataSection1
                
            }
        }
    }

    
}


extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        guard let index = firstIndex(of: object) else {return}
        remove(at: index)
        
    }
}










