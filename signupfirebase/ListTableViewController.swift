//
//  ListTableViewController.swift
//  signupfirebase
//
//  Created by Jan  on 05/12/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import CoreData
import UIKit

class ListTableViewController: UITableViewController {
    @IBOutlet var activity: UIActivityIndicatorView!
    var listItems = [NSManagedObject]()

    override func viewDidLoad() {
        super.viewDidLoad()

        activity.hidesWhenStopped = true
        activity.style = .gray
        view.addSubview(activity)

        activity.startAnimating()

        // Dette er ikke nødvendig når class er subclass av UITableViewController

        // For å få dette til å virke: må @IBOutlet weak var tableView: UITableView! være aktiv
        //        tableView.delegate = self
        //        tableView.dataSource = self

        // Alternativ måte er
        // Ctrl drag from TableView til den øverste gule iconen
        // Merk av delegate og dataSource
        // Da trengs ikke:  @IBOutlet weak var tableView: UITableView!

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")

        do {
            let result = try context.fetch(request)
            listItems = result as! [NSManagedObject]
        } catch {
            print("Error")
        }

        activity.stopAnimating()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ListTableViewCell

        // Configure the cell...

        let item = listItems[indexPath.row]

        cell.uidLabel?.text = item.value(forKey: "uid") as? String
        cell.mailLabel?.text = item.value(forKey: "email") as? String
        cell.nameLabel?.text = item.value(forKey: "name") as? String
        
        cell.passwordTextField?.isEnabled = false
        
        // Setter switchPassWord til av
        if (UserDefaults.standard.bool(forKey: "SHOWPASSWORD")) == true {
            cell.passwordTextField.isSecureTextEntry = false
        }
        else {
            cell.passwordTextField.isSecureTextEntry = true
        }
        
        cell.passwordTextField?.text = item.value(forKey: "password") as? String

        return cell
    }

    override func viewWillAppear(_ animated: Bool) {
        activity.startAnimating()

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")

        do {
            let result = try context.fetch(request)
            listItems = result as! [NSManagedObject]
        } catch {
            print("Error")
        }
        activity.stopAnimating()
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Slett") { (action, sourceView, completionHandler) in

            let item = self.listItems[indexPath.row]
            let userEmail = item.value(forKey: "email") as? String

            if self.deleteUserCoreData(UserEmail: String(describing: userEmail!))  == true {
            } else {
                let melding = NSLocalizedString("Unable to delete data in CoreData: ", comment: "ListTableViewController trailingSwipeActionsConfigurationForRowAt ")
                    + userEmail!
                
                self.presentAlert(withTitle: NSLocalizedString("Error", comment: "UpdatePasswordViewVontroller.swift SaveNewPassword "),
                                  message: melding)
            }

           // Call completion handler with true to indicate
            completionHandler(true)
        }
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        
        return swipeConfiguration
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
