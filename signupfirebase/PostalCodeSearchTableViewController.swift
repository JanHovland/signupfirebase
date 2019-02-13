//
//  PostalCodeSearchViewController.swift
//  signupfirebase
//
//  Created by Jan  on 21/01/2019.
//  Copyright © 2019 Jan . All rights reserved.
//

import Firebase
import UIKit

var globalCity = ""
var globalOldCity = ""
var globalPostalCode = ""
var globalOldPostalCode = ""

class PostalCodeSearchTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet var searchPostelCode: UISearchBar!
    @IBOutlet var tableViewSearch: UITableView!
    @IBOutlet var activity: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!

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

    var poststedsDictionary = [String: [PostalCode]]()
    var poststedSectionTitles = [String]()
    var poststeds = [String]()

    var sectionNo = 0

    // Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()

        makeRead()

        activity.style = .gray
        activity.isHidden = false

        searchPostelCode.delegate = self

        // Forces the online keyboard to be lowercased
        searchPostelCode.autocapitalizationType = UITextAutocapitalizationType.none

        globalOldCity = globalCity
        globalOldPostalCode = globalPostalCode
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
            let poststed1 = postValues[indexPath.row].poststed.lowercased()

            // Format poststed

            // capitalized : All word(s)' first letter will be in uppercase
            let poststed2 = poststed1.capitalized

            //  Replace " I " with " i "
            let poststed = poststed2.replacingOccurrences(of: " I ", with: " i ")

            let postnummer = postValues[indexPath.row].postnummer

            cell.poststedLabel?.text = poststed.capitalized

            cell.postnummerLabel?.text = postnummer

            cell.textLabel?.isHidden = true
            cell.textLabel?.text = postnummer

            // Format kommune

            let kommune1 = postValues[indexPath.row].kommune.lowercased()

            // capitalized : All word(s)' first letter will be in uppercase
            let kommune2 = kommune1.capitalized

            //  Replace " I " with " i "
            let kommune = kommune2.replacingOccurrences(of: " I ", with: " i ")

            let kommunenummer = postValues[indexPath.row].kommunenummer

            cell.kommuneInfoLabel?.text = kommunenummer + "  " + kommune.capitalized
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

        // Resetting all globals
        globalCity = ""
        globalPostalCode = ""

        if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
            // Find postalData. Returns postnummer, poststed, kommunenummer og kommune
            let value = findPostalData(postnummer: cell.textLabel!.text!)

            let count = poststedSectionTitles.count
            for index in 0 ..< count {
                if poststedSectionTitles[index] == String(value.1.prefix(1)) {
                    sectionNo = index
                    break
                }
            }

            // Delete all checkmarks in the active tableView
            deleteAllCheckmarks(section: sectionNo)

            // Sets the checkmark on the selected cell
            cell.accessoryType = .checkmark

            globalCity = value.1
            globalPostalCode = value.0
        }
    }

    // called when keyboard done button pressed
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchPostelCode.endEditing(true)
    }

    // Notifies the view controller that its view is about to be removed from a view hi
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if globalCity.count == 0 {
            globalCity = globalOldCity
        }

        if globalPostalCode.count == 0 {
            globalPostalCode = globalOldPostalCode
        }

        globalPersonNameText = postalCodeNameText
        globalPersonAddressText = postalCodeAddressText
        globalPersonPhoneNumberText = postalCodePhoneNumberText
        globalPersonDateOfBirthText = postalCodeDateOfBirthText
        globalPersonGenderInt = postalCodeGenderInt
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
    func makeRead() {
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
        var tempPostnr = [PostalCode]()

        db = Database.database().reference().child("postnr")

        db.observe(.value, with: { snapshot in

            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                    let postnr = childSnapshot.value as? [String: Any],
                    let postnummer = postnr["postnummer"] as? String,
                    let poststed = postnr["poststed"] as? String,
                    let kommunenummer = postnr["kommunenummer"] as? String,
                    let kommune = postnr["kommune"] as? String {
                    let postnr = PostalCode(poststed: poststed,
                                            postnummer: postnummer,
                                            kommune: kommune,
                                            kommunenummer: kommunenummer)

                    tempPostnr.append(postnr)
                }
            }

            // Update the tempPostnr array before updating the postelCodes
            // Sorting the postalCodes has no effect
            tempPostnr.sort(by: { $0.poststed < $1.poststed })
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
                let key = String(postalCodes[index].poststed.prefix(1))

                if var postValues = self.poststedsDictionary[key] {
                    postValues.append(PostalCode(poststed: postalCodes[index].poststed,
                                                 postnummer: postalCodes[index].postnummer,
                                                 kommune: postalCodes[index].kommune,
                                                 kommunenummer: postalCodes[index].kommunenummer))
                    poststedsDictionary[key] = postValues
                } else {
                    poststedsDictionary[key] = [PostalCode(poststed: postalCodes[index].poststed,
                                                           postnummer: postalCodes[index].postnummer,
                                                           kommune: postalCodes[index].kommune,
                                                           kommunenummer: postalCodes[index].kommunenummer)]
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
            searchedPostalCodes = postalCodes.filter({ $0.poststed.contains(searchText.uppercased()) })

            let count = searchedPostalCodes.count

            if count > 0 {
                let count = searchedPostalCodes.count - 1

                for index in 0 ... count {
                    let key = String(searchedPostalCodes[index].poststed.prefix(1))

                    if var postValues = self.poststedsDictionary[key] {
                        postValues.append(PostalCode(poststed: searchedPostalCodes[index].poststed,
                                                     postnummer: searchedPostalCodes[index].postnummer,
                                                     kommune: searchedPostalCodes[index].kommune,
                                                     kommunenummer: searchedPostalCodes[index].kommunenummer))
                        poststedsDictionary[key] = postValues
                    } else {
                        poststedsDictionary[key] = [PostalCode(poststed: searchedPostalCodes[index].poststed,
                                                               postnummer: searchedPostalCodes[index].postnummer,
                                                               kommune: searchedPostalCodes[index].kommune,
                                                               kommunenummer: searchedPostalCodes[index].kommunenummer)]
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
    func findPostalData(postnummer: String) -> (String, String, String, String) {
        let postalData = postalCodes.filter({ $0.postnummer.contains(postnummer) })

        if postalData.count == 1 {
            let postnummer = String(postalData[0].postnummer)
            let poststed = String(postalData[0].poststed)
            let kommunenummer = String(postalData[0].kommunenummer)
            let kommune = String(postalData[0].kommune)

            return (postnummer,
                    poststed,
                    kommunenummer,
                    kommune)
        } else {
            return ("",
                    "",
                    "",
                    "")
        }
    }
}
