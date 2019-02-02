//
//  PostalCodeSearchViewController.swift
//  signupfirebase
//
//  Created by Jan  on 21/01/2019.
//  Copyright © 2019 Jan . All rights reserved.
//

import UIKit
import Firebase

var city = ""
var oldCity = ""
var postalCode = ""
var oldPostalCode = ""

class PostalCodeSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    var postalCodes: [PostalCode] = []
    
    @IBOutlet var searchPostelCode: UISearchBar!
    @IBOutlet var tableView: UITableView!

    var searchedPostalCodes = [PostalCode]()
    var searching = false
    
    var postalCodeAddressText = ""
    var postalCodeCityText  = ""
    var postalCodeDateOfBirthText = ""
    var postalCodeFirstNameText = ""
    var postalCodeGenderInt = 0
    var postalCodeLastNameText = ""
    var postalCodePhoneNumberText = ""
    var postalCodePostalCodeNumberText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Read postalCode fra Firedata
        ReadPostalCodeFiredata(search: false, searchValue: "")
  
        // Sorting the postalCodes array on city
        postalCodes.sort(by: {$0.city < $1.city})
        
        searchPostelCode.delegate = self
        
        oldCity = city
        oldPostalCode = postalCode
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Read postalCode fra Firedata
        ReadPostalCodeFiredata(search: false, searchValue: "")
        postalCodes.sort(by: {$0.city < $1.city})
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Show the Navigation Bar
        self.navigationController?.setNavigationBarHidden(false, animated: true)
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

    func deleteAllCheckmarks() {
    
        // Delete all checkmarks in the ctive tableView
        let rowCount = self.tableView.numberOfRows(inSection: 0)
        for index in 0 ... rowCount {
            if let cell = self.tableView.cellForRow(at: NSIndexPath(row: index, section: 0) as IndexPath) {
                if cell.accessoryType == .checkmark {
                    cell.accessoryType = .none
                }
            }
        }
       
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedPostalCodes = postalCodes.filter({ $0.city.prefix(searchText.count) == searchText })
        searching = true
       
        // Delete all checkmarks in the ctive tableView
        deleteAllCheckmarks()

    }
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // Delete all checkmarks in the ctive tableView
        deleteAllCheckmarks()

        // Resetter postalCode and city
        postalCode = ""
        city = ""
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if city.count == 0 {
           city = oldCity
        }
        
        if postalCode.count == 0 {
           postalCode = oldPostalCode
        }
        
        globalPersonFirstNameText = postalCodeFirstNameText
        globalPersonLastNameText = postalCodeLastNameText
        globalPersonAddressText = postalCodeAddressText
        globalPersonPhoneNumberText = postalCodePhoneNumberText
        globalPersonDateOfBirthText = postalCodeDateOfBirthText
        globalPersonGenderInt = postalCodeGenderInt
        
   }
    
    // Tell the delegatewhen the scroll view is about to start scrolling the content
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // Delete all checkmarks in the ctive tableView
        deleteAllCheckmarks()
   }
    
    func ReadPostalCodeFiredata(search: Bool, searchValue: String) {
        
        var db: DatabaseReference!
        var postnrRef: DatabaseQuery!
        
        db = Database.database().reference().child("postnr")
        
        if search {
            postnrRef =  db.queryOrdered(byChild: "poststed").queryEqual(toValue: searchValue)
        } else {
            postnrRef =  db
        }
        
        postnrRef.observe(.value, with: { snapshot in
            
            var tempPostnr = [PostalCode]()
            
            for child in snapshot.children {
                
                if let childSnapshot = child as? DataSnapshot,
                    let postnr = childSnapshot.value as? [String: Any],
                    let postnummer = postnr["postnummer"] as? String,
                    let poststed = postnr["poststed"] as? String {
                    
                    let postnr = PostalCode(code: postnummer,
                                            city: poststed)
                    
                    
                    tempPostnr.append(postnr)
                    
                }
            }
            
            // Update the posts array
            self.postalCodes = tempPostnr
            
            // Sorting the persons array on firstName
            
            self.postalCodes.sort(by: {$0.city < $1.city})
            
            //            // Fill the table view
            //            self.tableView.reloadData()
            
            print(self.postalCodes.count)
            
            print("city = \(self.postalCodes[0].city as Any)")
            print("city = \(self.postalCodes[1].city as Any)")
            
        })
        
        
    }
    

    
    
}
