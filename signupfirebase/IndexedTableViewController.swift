//
//  ViewController.swift
//  IndexedTableView
//
//  Created by Jan  on 04/02/2019.
//  Copyright © 2019 Jan . All rights reserved.
//

import UIKit

class IndexedTableViewController: UITableViewController {
    
    var carsDictionary = [String: [String]]()
    var carSectionTitles = [String]()
    var cars = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cars = ["Audi", "Aston Martin","BMW", "Bugatti", "Bentley","Chevrolet", "Cadillac","Dodge","Ferrari", "Ford","Honda","Jaguar","Lamborghini","Mercedes", "Mazda","Nissan","Porsche","Rolls Royce","Toyota","Volkswagen"]
        
        for car in cars {
            let carKey = String(car.prefix(1))
            if var carValues = carsDictionary[carKey] {
                carValues.append(car)
                carsDictionary[carKey] = carValues
            } else {
                carsDictionary[carKey] = [car]
            }
        }
        
        carSectionTitles = [String](carsDictionary.keys)
        carSectionTitles = carSectionTitles.sorted(by: { $0 < $1 })
    }
    
    
    // MARK: - Table view data source
    
    // Asks the data source to return the number of sections in the table view.
    override func numberOfSections(in tableView: UITableView) -> Int {
        return carSectionTitles.count
    }
    
    // Tells the data source to return the number of rows in a given section of a table view.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let carKey = carSectionTitles[section]
        if let carValues = carsDictionary[carKey] {
            return carValues.count
        }
        
        return 0
    }
    
    // Asks the data source for a cell to insert in a particular location of the table view.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Configure the cell...
        let carKey = carSectionTitles[indexPath.section]
        if let carValues = carsDictionary[carKey] {
            cell.textLabel?.text = carValues[indexPath.row]
        }
        
        return cell
    }
    
    // Asks the data source for the title of the header of the specified section of the table view.
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return carSectionTitles[section]
    }
    
    // Asks the data source to return the titles for the sections for a table view.
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return carSectionTitles
    }
    
    // Sent to the view controller when the app receives a memory warning.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
    
