//
//  BirthdayTableViewController.swift
//  signupfirebase
//
//  Created by Jan Hovland on 27/04/2019.
//  Copyright © 2019 Jan . All rights reserved.
//

import UIKit

class BirthdayTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.makeReadPersons()
        }
        
        persons.sort(by: {$0.personData.dateOfBirth2 < $1.personData.dateOfBirth2})

        tableView.reloadData()
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellBirthday", for: indexPath) as! BirthdayTableViewCell

        // There is now no selectionStyle of the selected cell (.default, .blue, .gray or ,none)
        cell.selectionStyle = .none
        
        let birthDay = persons[indexPath.row].personData.dateOfBirth1
        if let secondSpace = birthDay.lastIndex(of: " ") {
           cell.birthdayLabel.text = String(birthDay[..<secondSpace])
        }
        
        cell.nameLabel.text = persons[indexPath.row].personData.firstName + " " + persons[indexPath.row].personData.lastName
        
        return cell
        
    }
 
}

