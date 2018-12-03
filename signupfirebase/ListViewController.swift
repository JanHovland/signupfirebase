//
//  ListViewController.swift
//  signupfirebase
//
//  Created by Jan  on 02/12/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var listItems = [NSManagedObject]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activity.hidesWhenStopped = true
        activity.style = .gray
        view.addSubview(activity)

        activity.startAnimating()
        
        // For å få dette til å virke: må @IBOutlet weak var tableView: UITableView! være aktiv
        tableView.delegate = self
        tableView.dataSource = self

        // Alternativ måte er
        // Ctrl drag from TableView til den øverste gule iconen
        // Merk av delegate og dataSource
        // Da trengs ikke:  @IBOutlet weak var tableView: UITableView!
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        
        do {
            let result = try context.fetch(request)
            listItems = result as! [NSManagedObject]
        }
        catch {
            print("Error")
        }
 
        activity.stopAnimating()
  }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        
        activity.startAnimating()
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        
        do {
            let result = try context.fetch(request)
            listItems = result as! [NSManagedObject]
        }
        catch {
            print("Error")
        }
        activity.stopAnimating()
        
    }

}

