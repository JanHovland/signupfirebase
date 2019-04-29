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
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellBirthday", for: indexPath) as! BirthdayTableViewCell

        cell.birthdayLabel.text = persons[indexPath.row].personData.dateOfBirth1
        cell.nameLabel.text = persons[indexPath.row].personData.firstName + " " + persons[indexPath.row].personData.lastName
        return cell
    }
    

}

extension Date {
    func asString() -> String {
      let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
}
