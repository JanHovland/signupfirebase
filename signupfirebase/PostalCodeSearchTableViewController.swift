//
//  PostalCodeSearchViewController.swift
//  signupfirebase
//
//  Created by Jan  on 21/01/2019.
//  Copyright © 2019 Jan . All rights reserved.
//

import Firebase
import UIKit

class PostalCodeSearchTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet var searchPostelCode: UISearchBar!
    @IBOutlet var tableViewSearch: UITableView!
    @IBOutlet var activity: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!

    var postalCodes = [PostalCode]()
    var searchedPostalCodes = [PostalCode]()
    var searching = false
    
    var poststedsDictionary = [String: [PostalCode]]()
    var poststedSectionTitles = [String]()
    var sectionNo = 0

    // Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()

        makeReadPostal()

        activity.style = UIActivityIndicatorView.Style.medium
        activity.isHidden = false

        searchPostelCode.delegate = self

        // Forces the online keyboard to be lowercased
        searchPostelCode.autocapitalizationType = UITextAutocapitalizationType.none

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
    }

    // Asks the data source for a cell to insert in a particular location of the table view.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SearchedPostelCodesTableViewCell

        let key = poststedSectionTitles[indexPath.section]

        if let postValues = poststedsDictionary[key] {
            let poststed1 = postValues[indexPath.row].postPlace.lowercased()

            // Format poststed

            // capitalized : All word(s)' first letter will be in uppercase
            let poststed2 = poststed1.capitalized

            //  Replace " I " with " i "
            let poststed = poststed2.replacingOccurrences(of: " I ", with: " i ")

            let postnummer = postValues[indexPath.row].postNumber
            
            cell.cityLabel?.text = poststed.capitalized
            cell.postalCodeLabel?.text = postnummer

            cell.textLabel?.isHidden = true
            cell.textLabel?.text = postnummer

            // Format kommune

            let municipality1 = postValues[indexPath.row].municipality.lowercased()

            // capitalized : All word(s)' first letter will be in uppercase
            let municipality2 = municipality1.capitalized

            //  Replace " I " with " i "
            let municipality = municipality2.replacingOccurrences(of: " I ", with: " i ")

            let kommunenummer = postValues[indexPath.row].municipalityNumber

            cell.municipalityInfoLabel?.text = kommunenummer + "  " + municipality.capitalized
            
        }

        return cell
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
            searching = true
        } else {
            searching = false
        }

        // Search
        FindSearchedPostalCodes(searchText: searchText)

        // Fill the table view
        tableView.reloadData()
    }

    // Tells the delegate that the specified row is now selected.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
            // Find postalData. Returns postnummer, poststed, kommunenummer og kommune
            let value = findPostalData(postNumber: cell.textLabel!.text!)

            let count = poststedSectionTitles.count
            for index in 0 ..< count {
                if poststedSectionTitles[index] == String(value.postPlace.prefix(1)) {
                    sectionNo = index
                    break
                }
            }

            // Delete all checkmarks in the active tableView
            deleteAllCheckmarks(section: sectionNo)

            // Sets the checkmark on the selected cell
            cell.accessoryType = .checkmark
            
            
            // Set the global variables
            globalCityCodeNumber = value.postNumber
            globalCity = value.postPlace
            
            globalMunicipality = value.municipality
            globalMunicipalityNumber = value.municipalityNumber
            
        }
    }

    // called when keyboard done button pressed
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchPostelCode.endEditing(true)
    }

    // Notifies the view controller that its view is about to be removed from a view hi
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
 
    }

    // Tell the delegatewhen the scroll view is about to start scrolling the content
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // Delete all checkmarks in the active tableView
        deleteAllCheckmarks(section: sectionNo)
    }

    // Delete all checkmarks in the active tableView
    func deleteAllCheckmarks(section: Int) {
        let rowCount = tableView.numberOfRows(inSection: section)

        for index in 0 ... rowCount {
            if let cell = self.tableView.cellForRow(at: NSIndexPath(row: index, section: section) as IndexPath) {
                if cell.accessoryType == .checkmark {
                    cell.accessoryType = .none
                }
            }
        }
    }

    // Reads all data outside the closure in ReadPostalCodeFiredata
    func makeReadPostal() {
        ReadPostalCodeFiredata { _ in

            // Must use the main thread to get the data
            // DispatchQueue manages the execution of work items.
            // Each work item submitted to a queue is processed on a pool of threads managed by the system.
            DispatchQueue.main.async {
                self.FindSearchedPostalCodes(searchText: "")
            }
        }
    }

    // Read postal data from Firebase and exports the tempPostnr array from the closure when finshed
    func ReadPostalCodeFiredata(completionHandler: @escaping (_ tempPostnr: [PostalCode]) -> Void) {
 
        var db: DatabaseReference!
        
        db = Database.database().reference().child("postnr")

        db.observe(.value, with: { snapshot in

            var tempPostnr = [PostalCode]()
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                    let postnr = childSnapshot.value as? [String: Any],
                    let postNumber = postnr["postnummer"] as? String,
                    let postPlace = postnr["poststed"] as? String,
                    let municipalityNumber = postnr["kommunenummer"] as? String,
                    let municipality = postnr["kommune"] as? String {
                    let postnr = PostalCode(postPlace: postPlace,
                                            postNumber: postNumber,
                                            municipality: municipality,
                                            municipalityNumber: municipalityNumber)

                    tempPostnr.append(postnr)
                }
            }

            // Update the tempPostnr array before updating the postelCodes
            // Sorting the postalCodes has no effect
            tempPostnr.sort(by: { $0.postPlace < $1.postPlace })
            self.postalCodes = tempPostnr

            // Export the data from the closure
            completionHandler(tempPostnr)

        })
    }

    func FindSearchedPostalCodes(searchText: String) {
        // Reset poststedsDictionary
        poststedsDictionary = [String: [PostalCode]]()

        if searchText.count == 0 {
            let count = postalCodes.count - 1

            for index in 0 ... count {
                let key = String(postalCodes[index].postPlace.prefix(1))

                if var postValues = self.poststedsDictionary[key] {
                    postValues.append(PostalCode(postPlace: postalCodes[index].postPlace,
                                                 postNumber: postalCodes[index].postNumber,
                                                 municipality: postalCodes[index].municipality,
                                                 municipalityNumber: postalCodes[index].municipalityNumber))
                    poststedsDictionary[key] = postValues
                } else {
                    poststedsDictionary[key] = [PostalCode(postPlace: postalCodes[index].postPlace,
                                                           postNumber: postalCodes[index].postNumber,
                                                           municipality: postalCodes[index].municipality,
                                                           municipalityNumber: postalCodes[index].municipalityNumber)]
                }
            }

            poststedSectionTitles = [String](poststedsDictionary.keys)

            // Must use local sorting of the poststedSectionTitles
            let region = NSLocale.current.regionCode?.lowercased() // Returns the local region
            let language = Locale(identifier: region!)
            let sortedpoststedSection1 = poststedSectionTitles.sorted {
                $0.compare($1, locale: language) == .orderedAscending
            }
            poststedSectionTitles = sortedpoststedSection1

            // Fill the table view
            tableView.reloadData()

        } else {
            
            searchedPostalCodes = postalCodes.filter({ $0.postPlace.contains(searchText.uppercased()) })

            let count = searchedPostalCodes.count

            if count > 0 {
                let count = searchedPostalCodes.count - 1

                for index in 0 ... count {
                    let key = String(searchedPostalCodes[index].postPlace.prefix(1))

                    if var postValues = self.poststedsDictionary[key] {
                        
                        postValues.append(PostalCode(postPlace: searchedPostalCodes[index].postPlace,
                                                     postNumber: searchedPostalCodes[index].postNumber,
                                                     municipality: searchedPostalCodes[index].municipality,
                                                     municipalityNumber: searchedPostalCodes[index].municipalityNumber))
                        
                        poststedsDictionary[key] = postValues
                        
                    } else {
                        poststedsDictionary[key] = [PostalCode(postPlace: searchedPostalCodes[index].postPlace,
                                                               postNumber: searchedPostalCodes[index].postNumber,
                                                               municipality: searchedPostalCodes[index].municipality,
                                                               municipalityNumber: searchedPostalCodes[index].municipalityNumber)]
                    }
                }
            }

            poststedSectionTitles = [String](poststedsDictionary.keys)

            // Must use local sorting of the poststedSectionTitles
            let region = NSLocale.current.regionCode?.lowercased() // Returns the local region
            let language = Locale(identifier: region!)
            let sortedpoststedSection1 = poststedSectionTitles.sorted {
                $0.compare($1, locale: language) == .orderedAscending
            }
            poststedSectionTitles = sortedpoststedSection1

            // Fill the table view
            tableView.reloadData()
        }
    }

    // Find postalData. Returns postnummer, poststed, kommunenummer og kommune
    func findPostalData(postNumber: String) -> (postNumber: String,
                                                postPlace: String,
                                                municipalityNumber: String,
                                                municipality: String) {
                                                    
        let postalData = postalCodes.filter({ $0.postNumber.contains(postNumber) })

        if postalData.count == 1 {
            
            let postnummer = String(postalData[0].postNumber)
            let postPlace1 = String(postalData[0].postPlace).lowercased()
            let postPlace = postPlace1.capitalized
            let kommunenummer = String(postalData[0].municipalityNumber)
            let municipality1 = String(postalData[0].municipality).lowercased()
            let municipality = municipality1.capitalized
     
            return (postnummer,
                    postPlace,
                    kommunenummer,
                    municipality)
        } else {
            return ("",
                    "",
                    "",
                    "")
        }
    }
}
