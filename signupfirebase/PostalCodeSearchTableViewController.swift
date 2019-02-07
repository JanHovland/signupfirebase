//
//  PostalCodeSearchViewController.swift
//  signupfirebase
//
//  Created by Jan  on 21/01/2019.
//  Copyright © 2019 Jan . All rights reserved.
//

import Firebase
import UIKit

var city = ""
var oldCity = ""
var postalCode = ""
var oldPostalCode = ""

class PostalCodeSearchTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet var searchPostelCode: UISearchBar!
    @IBOutlet weak var tableViewSearch: UITableView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    var postalCodes = [PostalCode]()
    var searchedPostalCodes = [PostalCode]()
    var searching = false

    var postalCodeAddressText = ""
    var postalCodeCityText = ""
    var postalCodeDateOfBirthText = ""
    var postalCodeNameText = ""
    var postalCodeGenderInt = 0
    var postalCodePhoneNumberText = ""
    var postalCodePostalCodeNumberText = ""
    
    var poststedsDictionary = [String: [String]]()
    var poststedSectionTitles = [String]()
    var poststeds = [String]()

    // Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()

        makeRead()
        
        activity.style = .gray
        activity.isHidden = false

        searchPostelCode.delegate = self

        oldCity = city
        oldPostalCode = postalCode
    }

    // Notifies the view controller that its view was added to a view hierarchy.
    override func viewDidAppear(_ animated: Bool) {
        activity.startAnimating()
        
        activity.isHidden = true
        activity.stopAnimating()
    }

    // Notifies the view controller that its view is about to be added to a view hierarchy.
    override func viewWillAppear(_ animated: Bool) {
        // Show the Navigation Bar
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    // Asks the data source to return the number of sections in the table view.
    func numberOfSections(in tableView: UITableView) -> Int {
        return poststedSectionTitles.count
    }
    
    // Asks the data source to return the number of sections in the table view.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = poststedSectionTitles[section]
        if let postValues = poststedsDictionary[key] {
            return postValues.count
        }
        
        return 0
        
//        if searching {
//            return searchedPostalCodes.count
//        } else {
//            return postalCodes.count
//        }
    }

    // Asks the data source for a cell to insert in a particular location of the table view.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")

        let key = poststedSectionTitles[indexPath.section]
        if let postValues = poststedsDictionary[key] {
            cell?.textLabel?.text = postValues[indexPath.row]
        }
        
        // Configure the cell
//        if searching {
//            cell?.textLabel?.text = searchedPostalCodes[indexPath.row].postnummer
//            cell?.detailTextLabel?.text = searchedPostalCodes[indexPath.row].poststed
//        } else {
//            cell?.textLabel?.text = postalCodes[indexPath.row].postnummer
//            cell?.detailTextLabel?.text = postalCodes[indexPath.row].poststed
//        }

        return cell!
    }
    
    // Asks the data source for the title of the header of the specified section of the table view.
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return poststedSectionTitles[section]
    }
    
    // Asks the data source to return the titles for the sections for a table view.
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return poststedSectionTitles
    }

    // Tells the delegate that the user changed the search text.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            searchedPostalCodes = postalCodes.filter({ $0.poststed.contains(searchText.uppercased()) })
            searching = true
        } else {
            searching = false
        }

        // Delete all checkmarks in the ctive tableView
        deleteAllCheckmarks()

        // Fill the table view
        tableView.reloadData()
    }
    
    // Tells the delegate that the specified row is now selected.
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

    // Notifies the view controller that its view is about to be removed from a view hi
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

    // Delete all checkmarks in the active tableView
    func deleteAllCheckmarks() {
        let rowCount = tableView.numberOfRows(inSection: 0)
        for index in 0 ... rowCount {
            if let cell = self.tableView.cellForRow(at: NSIndexPath(row: index, section: 0) as IndexPath) {
                if cell.accessoryType == .checkmark {
                    cell.accessoryType = .none
                }
            }
        }
    }
    
    // Reads all data outside the closure in ReadPostalCodeFiredata
    func makeRead() {
        ReadPostalCodeFiredata { (postalCodes) in
            
            // Must use the main thread to get the data
            // DispatchQueue manages the execution of work items.
            // Each work item submitted to a queue is processed on a pool of threads managed by the system.
            DispatchQueue.main.async {
                
                /*
                var poststedsDictionary = [String: [String]]()
                var poststedSectionTitles = [String]()
                var poststeds = [String]()
                var postalCodes = [PostalCode]()
                */
                
                let count = postalCodes.count - 1
                
                for index in 0...count {
                    
                    let key = String(postalCodes[index].poststed.prefix(1))
                    
                    if var postValues = self.poststedsDictionary[key] {
                        postValues.append(postalCodes[index].poststed)
                        self.poststedsDictionary[key] = postValues
                    } else {
                        self.poststedsDictionary[key] = [postalCodes[index].poststed]
                    }
   
                }
                
                self.poststedSectionTitles = [String](self.poststedsDictionary.keys)
                
                // Must use local sorting of the poststedSectionTitles
                let region = NSLocale.current.regionCode?.lowercased()  // Returns the local region
                let language = Locale(identifier: region!)
                let sortedpoststedSection1 = self.poststedSectionTitles.sorted {
                    $0.compare($1, locale: language) == .orderedAscending
                }
                self.poststedSectionTitles = sortedpoststedSection1
             
                print("self.poststedSectionTitles = \(self.poststedSectionTitles)")
                
                // Fill the table view
                self.tableView.reloadData()

            }
        }
    }
    
    // Read postal data from Firebase and exports the array from the closure when finshed
    func ReadPostalCodeFiredata(completionHandler: @escaping (_ tempPostnr: [PostalCode]) ->Void) {
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
            self.postalCodes.sort(by: { $0.poststed < $1.poststed })
            
            // Export the data from the closure
            completionHandler(tempPostnr)

        })
        
    }
}
