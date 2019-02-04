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

    @IBOutlet var searchPostelCode: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    var postalCodes = [PostalCode]()
    
    var searchedPostalCodes = [PostalCode]()
    var searching = false
    
    var postalCodeAddressText = ""
    var postalCodeCityText  = ""
    var postalCodeDateOfBirthText = ""
    var postalCodeNameText = ""
    var postalCodeGenderInt = 0
    var postalCodePhoneNumberText = ""
    var postalCodePostalCodeNumberText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activity.style = .gray
        activity.isHidden = false

        searchPostelCode.delegate = self
        
        oldCity = city
        oldPostalCode = postalCode
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        activity.startAnimating()
        
        // Read postalCode fra Firedata
        ReadPostalCodeFiredata()
        
        activity.isHidden = true
        activity.stopAnimating()
        
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
            cell?.textLabel?.text = searchedPostalCodes[indexPath.row].postnummer
            cell?.detailTextLabel?.text = searchedPostalCodes[indexPath.row].poststed
        } else {
            cell?.textLabel?.text = postalCodes[indexPath.row].postnummer
            cell?.detailTextLabel?.text = postalCodes[indexPath.row].poststed 
        }
//        // Fill the table view
//        self.tableView.reloadData()
        
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
       
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count > 0 {
            searchedPostalCodes = postalCodes.filter({$0.poststed.contains(searchText.uppercased())})
            searching = true
        } else {
 print("searchText = \(searchText)")
            searching = false
        }
           
        // Delete all checkmarks in the ctive tableView
        deleteAllCheckmarks()
        
        // Fill the table view
        tableView.reloadData()

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

    // called when keyboard done button pressed
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchPostelCode.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if city.count == 0 {
           city = oldCity
        }
        
        if postalCode.count == 0 {
           postalCode = oldPostalCode
        }
        
        globalPersonNameText = postalCodeNameText
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
    
    func ReadPostalCodeFiredata() {
        
        var db: DatabaseReference!
        
        db = Database.database().reference().child("postnr")
        
        db.observe(.value, with: { snapshot in
            
            var tempPostnr = [PostalCode]()
            
            for child in snapshot.children {
                
                if let childSnapshot = child as? DataSnapshot,
                    let postnr = childSnapshot.value as? [String: Any],
                    let postnummer = postnr["postnummer"] as? String,
                    let poststed = postnr["poststed"] as? String,
                    let kommunenummer = postnr["kommunenummer"] as? String,
                    let kommune = postnr["kommune"] as? String {
                    
                    let postnr = PostalCode(postnummer: postnummer,
                                            poststed: poststed,
                                            kommunenummer: kommunenummer,
                                            kommune: kommune)
                    
                    tempPostnr.append(postnr)
                    
                }
            }
            
            // Update the posts array
            self.postalCodes = tempPostnr
            
            // Sorting the persons array on firstName
            self.postalCodes.sort(by: {$0.poststed < $1.poststed})
            
            // Fill the table view
            self.tableView.reloadData()
            
        })
    }
    
    
}
