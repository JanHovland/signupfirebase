//
//  PostalCodeSearchViewController.swift
//  signupfirebase
//
//  Created by Jan  on 21/01/2019.
//  Copyright © 2019 Jan . All rights reserved.
//

import UIKit

class PostalCodeSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var postalCodes : [PostalCode] = [
        
        PostalCode(code: "1311", city: "Høvikodden", index: false),
        PostalCode(code: "1312", city: "Slependen", index: false)
        
    ]
    
    @IBOutlet weak var searchPostelCode: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    
    var searchedPostalCodes = [PostalCode]()
    
    var searching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        searchedPostalCodes = postalCodes.filter({$0.city.prefix(searchText.count) == searchText})  
        searching = true
        tableView.reloadData()
    }
    
// gotoPersondataFromPostalCode
    
    
    @IBAction func doneButton(_ sender: Any) {
        
        print(postalCodes[0].city)
        
    }
    
    
    
    
    
    
    
    
    
    
    
}
