//
//  PostalCodeSearchViewController.swift
//  signupfirebase
//
//  Created by Jan  on 21/01/2019.
//  Copyright © 2019 Jan . All rights reserved.
//

import UIKit

class PostalCodeSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    var postalCodes: [PostalCode] = [
        PostalCode(code: "1311", city: "Høvikodden"),
        PostalCode(code: "1312", city: "Slependen"),
    ]

    @IBOutlet var searchPostelCode: UISearchBar!
    @IBOutlet var tableView: UITableView!

    var searchedPostalCodes = [PostalCode]()
    var searching = false
    var checked = [Bool]()
    
    var city = ""
    var postalCode = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set all checkmarks to false
        checked = Array(repeating: false, count: postalCodes.count)

        searchPostelCode.delegate = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchedPostalCodes.count
        } else {
            return postalCodes.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")

        // Configure the cell
        if searching {
            cell?.textLabel?.text = searchedPostalCodes[indexPath.row].code
            cell?.detailTextLabel?.text = searchedPostalCodes[indexPath.row].city
        } else {
            cell?.textLabel?.text = postalCodes[indexPath.row].code
            cell?.detailTextLabel?.text = postalCodes[indexPath.row].city
        }

        return cell!
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedPostalCodes = postalCodes.filter({ $0.city.prefix(searchText.count) == searchText })
        searching = true
        tableView.reloadData()
    }

    @IBAction func doneButton(_ sender: Any) {
        
        if city.count > 0 {
        
            // Here are the selected values for code and city
            // Must be passed to Update Person
            
            
            
            
            print("Antall tegn i city = " + (String(city.count) + " " + postalCode + " " + city) as Any)
        } else {
            let melding = NSLocalizedString("You must select a postal code with a corresponding city",
                                            comment: "PostalCodeSearchViewController doneButton")
            
            self.presentAlert(withTitle: NSLocalizedString("Postal Codes",
                                                           comment: "PostalCodeSearchViewController doneButton"),
                              message: melding)
        }
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // Delete all checkmarks
        let rowCount = tableView.numberOfRows(inSection: 0)
        for index in 0 ... rowCount {
            if let cell = tableView.cellForRow(at: NSIndexPath(row: index, section: 0) as IndexPath) {
                if cell.accessoryType == .checkmark {
                    cell.accessoryType = .none
                }
            }
        }

        // Set a checkmark at cellForRow and
        // Store the selected city and postalCode
        if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
            cell.accessoryType = .checkmark
            city = String(cell.detailTextLabel!.text!)
            postalCode = String(cell.textLabel!.text!)
        }
    }

    // Close the onboard keyboard
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchPostelCode.endEditing(true)
        searchPostelCode.text = ""
    }
    
}
