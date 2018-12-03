//
//  ListTableViewController.swift
//  signupfirebase
//
//  Created by Jan  on 03/12/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import UIKit
import CoreData

class ListTableViewController: UITableViewController {

    var listItems = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        
        do {
            let result = try context.fetch(request)
            listItems = result as! [NSManagedObject]
        }
        catch {
            print("Error")
        }
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CoreDataTableViewCell
        
        // Configure the cell...
        
        let item = listItems[indexPath.row]
        
        cell.uidLabel?.text = item.value(forKey: "uid") as? String
        cell.mailLabel?.text = item.value(forKey: "email") as? String
        cell.nameLabel?.text = item.value(forKey: "name") as? String
        
        print(cell.uidLabel?.text as Any)
        
        
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        
        do {
            let result = try context.fetch(request)
            listItems = result as! [NSManagedObject]
        }
        catch {
            print("Error")
        }
    }

}
