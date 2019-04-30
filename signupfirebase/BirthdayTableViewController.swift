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

        let refreshControl = UIRefreshControl()
        // refreshControl.attributedTitle = NSAttributedString(string: "Skyv nedover for å hente data")
        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        self.tableView.refreshControl = refreshControl
        
        tableView.reloadData()
        
   }
    
    @objc func reloadData() {
        DispatchQueue.main.async {
            persons.sort(by: {$0.personData.dateOfBirth2 < $1.personData.dateOfBirth2})
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
        }
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
        
        cell.backgroundColor = .white
        
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
                cell.birthdayLabel.backgroundColor = .green
            } else {
                cell.birthdayLabel.backgroundColor = .white
            }
           
        }
        
        cell.nameLabel.text = persons[indexPath.row].personData.firstName + " " + persons[indexPath.row].personData.lastName
        
        return cell
        
    }
 
}

