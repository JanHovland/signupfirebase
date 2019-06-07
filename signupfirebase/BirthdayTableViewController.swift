//
//  BirthdayTableViewController.swift
//  signupfirebase
//
//  Created by Jan Hovland on 27/04/2019.
//  Copyright © 2019 Jan . All rights reserved.
//

import UIKit

class BirthdayTableViewController: UITableViewController {
    
    var phoneNumber: String = ""
    var firstName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        let message = NSLocalizedString("Slide down to retrieve data", comment: "BirthdayTableViewController.swift viewDidLoad")
        
        refreshControl.attributedTitle = NSAttributedString(string: message)
        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        self.tableView.refreshControl = refreshControl
        
    }
    
    // Called when the view is about to made visible. Default does nothing
    override func viewWillAppear(_ animated: Bool) {
       persons.sort(by: {$0.personData.dateOfBirth2 < $1.personData.dateOfBirth2})
    }
    
    @objc func reloadData() {
        self.tableView.reloadData()
        self.tableView.refreshControl?.endRefreshing()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return persons.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var str: String = ""
        var month: Int = 0
        var monthFromDate: Int = 0
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellBirthday", for: indexPath) as! BirthdayTableViewCell

        // There is now no selectionStyle of the selected cell (.default, .blue, .gray or ,none)
        cell.selectionStyle = .none
        
        cell.backgroundColor = .systemBackground
        
        
        
        let birthDay = persons[indexPath.row].personData.dateOfBirth1
        if let secondSpace = birthDay.lastIndex(of: " ") {
           cell.birthdayLabel.text = String(birthDay[..<secondSpace])
           str = String(birthDay[..<secondSpace])
        }
        
        if let periode = str.firstIndex(of: " ") {
            
           let month1 = str[periode...]
            
           let month2 = month1.replacingOccurrences(of: " ", with: "")
        
            if month2         == NSLocalizedString("january", comment: "BirthdayTableViewController.swift cellForRowAt") {
                month = 1
            } else if  month2 == NSLocalizedString("february", comment: "BirthdayTableViewController.swift cellForRowAt") {
                month = 2
            } else if  month2 == NSLocalizedString("march", comment: "BirthdayTableViewController.swift cellForRowAt") {
                month = 3
            } else if  month2 == NSLocalizedString("april", comment: "BirthdayTableViewController.swift cellForRowAt") {
                month = 4
            } else if  month2 == NSLocalizedString("may", comment: "BirthdayTableViewController.swift cellForRowAt") {
                month = 5
            } else if  month2 == NSLocalizedString("june", comment: "BirthdayTableViewController.swift cellForRowAt") {
                month = 6
            } else if  month2 == NSLocalizedString("july", comment: "BirthdayTableViewController.swift cellForRowAt") {
                month = 7
            } else if  month2 == NSLocalizedString("august", comment: "BirthdayTableViewController.swift cellForRowAt") {
                month = 8
            } else if  month2 == NSLocalizedString("september", comment: "BirthdayTableViewController.swift cellForRowAt") {
                month = 9
            } else if  month2 == NSLocalizedString("october", comment: "BirthdayTableViewController.swift cellForRowAt") {
                month = 10
            } else if  month2 == NSLocalizedString("november", comment: "BirthdayTableViewController.swift cellForRowAt") {
                month = 11
            } else if  month2 == NSLocalizedString("december", comment: "BirthdayTableViewController.swift cellForRowAt") {
                month = 12
            }

            let date = Date()
            let calendar = Calendar.current
            monthFromDate = calendar.component(.month, from: date)
            
            if month == monthFromDate {
                cell.birthdayLabel.backgroundColor = .systemGreen
            } else {
                cell.birthdayLabel.backgroundColor = .systemBackground
            }
           
        }
        
        cell.nameLabel.text = persons[indexPath.row].personData.firstName + " " + persons[indexPath.row].personData.lastName
        
        return cell
        
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {

        var idx = 0
        var personIndex = -1
        
        let numberOfPersons = persons.count
        
        if numberOfPersons > 0 {
        
            // Find the row of the selected cell
            let buttonPosition = sender.convert(sender.bounds.origin, to: tableView)
            if let indexPath = tableView.indexPathForRow(at: buttonPosition) {
                tableView.deselectRow(at: indexPath, animated: true)
                let cell = tableView.cellForRow(at: indexPath) as! BirthdayTableViewCell
                selectedName = String(cell.nameLabel!.text!)
                
                // Find the selected person
                repeat {
                    if persons[idx].personData.name.uppercased() == selectedName.uppercased() {
                        personIndex = idx
                        idx = numberOfPersons
                    }
                    idx += 1
                } while (idx < numberOfPersons)

                if personIndex >= 0 {
                    phoneNumber = String(persons[personIndex].personData.phoneNumber)
                    firstName = String(persons[personIndex].personData.firstName)
                    performSegue(withIdentifier: "gotoMessageFromBirthday", sender: nil)
                }

            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! BirthdayTableViewCell

        selectedName = String(cell.nameLabel!.text!)
        performSegue(withIdentifier: "goBackToPersonData", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "gotoMessageFromBirthday" {
            
            let vc = segue.destination as! MessageViewController
            
            vc.messageBody = "Gratulerer så mye med fødselsdagen " + firstName + " 🇳🇴 😄"
            vc.messagePhoneNumber = phoneNumber
            vc.messageId = "fromBirthday"
            
        } else if segue.identifier! == "goBackToPersonData" {
            
            var idx = 0
            var personIndex = -1
            
            let numberOfPersons = persons.count
            
            if numberOfPersons > 0 {
                
                // Find the selected person
                repeat {
                    if persons[idx].personData.name.uppercased() == selectedName.uppercased() {
                        personIndex = idx
                        idx = numberOfPersons
                    }
                    idx += 1
                } while (idx < numberOfPersons)
                
                if personIndex >= 0 {
                    
                    let vc = segue.destination as! PersonViewController
                    
                    vc.PersonAddressText = String(persons[personIndex].personData.address)
                    vc.PersonCityText = String(persons[personIndex].personData.city)
                    vc.PersonDateOfBirthText1 = String(persons[personIndex].personData.dateOfBirth1)
                    vc.PersonDateOfBirthText2 = String(persons[personIndex].personData.dateOfBirth2)
                    vc.PersonFirstNameText = String(persons[personIndex].personData.firstName)
                    vc.PersonGenderInt = persons[personIndex].personData.gender
                    vc.PersonIdText = String(persons[personIndex].id)
                    vc.PersonLastNameText = String(persons[personIndex].personData.lastName)
                    vc.PersonMunicipalityNumberText = String(persons[personIndex].personData.municipalityNumber)
                    vc.PersonMunicipalityText = String(persons[personIndex].personData.municipality)
                    vc.PersonOption = 1         // Update == 1
                    vc.PersonPersonEmailText = String(persons[personIndex].personData.personEmail)
                    vc.PersonPhoneNumberText = String(persons[personIndex].personData.phoneNumber)
                    vc.PersonPhotoURL = String(persons[personIndex].personData.photoURL)
                    vc.PersonPostalCodeNumberText = String(persons[personIndex].personData.postalCodeNumber)
                    vc.PersonTitle = NSLocalizedString("Update Person", comment: "BirthdayTableViewController.swift prepare")
                    
                    // Initialize the globals
                    globalAddress = String(persons[personIndex].personData.address)
                    globalCity = String(persons[personIndex].personData.city)
                    globalCityCodeNumber = String(persons[personIndex].personData.postalCodeNumber)
                    globalDateOfBirth = String(persons[personIndex].personData.dateOfBirth1)
                    globalFirstName = String(persons[personIndex].personData.firstName)
                    globalGender = persons[personIndex].personData.gender
                    globalLastName = String(persons[personIndex].personData.lastName)
                    globalMunicipalityNumber = String(persons[personIndex].personData.municipalityNumber)
                    globalMunicipality = String(persons[personIndex].personData.municipality)
                    globalPersonEmail = String(persons[personIndex].personData.personEmail)
                    globalPhoneNumber = String(persons[personIndex].personData.phoneNumber)

                  
                }
            }
            
        }
    }
    
    
    
}

