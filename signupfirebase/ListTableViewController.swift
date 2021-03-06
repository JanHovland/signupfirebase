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
        
        tableView.backgroundColor = .systemBackground
  
        activity.hidesWhenStopped = true
        activity.style = UIActivityIndicatorView.Style.medium
        view.addSubview(activity)

        activity.startAnimating()

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")

        do {
            let result = try context.fetch(request)
            listItems = result as! [NSManagedObject]
        } catch {
       
            let message = error.localizedDescription
            self.presentAlert(withTitle: NSLocalizedString("Error", comment: "ListTableViewController viewDidLoad"),
                              message: message)

        }

        activity.stopAnimating()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ListTableViewCell
        
        // Must update the colors and background (Early version ?)
        
        cell.backgroundColor = .systemBackground
    
        // Configure the cell...

        let item = listItems[indexPath.row]

        cell.nameLabel?.text = item.value(forKey: "name") as? String
        cell.nameLabel?.textColor = .label

        cell.passwordTextField?.isEnabled = false
        
        // Set the 'switchPassWord' to OFF
        if (UserDefaults.standard.bool(forKey: "SHOWPASSWORD")) == true {
            cell.passwordTextField.isSecureTextEntry = false
        }
        else {
            cell.passwordTextField.isSecureTextEntry = true
        }
        
        cell.passwordTextField?.text = item.value(forKey: "password") as? String
        cell.passwordTextField?.textColor = .label
        
        cell.mailLabel?.text = item.value(forKey: "email") as? String
        cell.mailLabel?.textColor = .label

        cell.uidLabel?.text = item.value(forKey: "uid") as? String
        cell.uidLabel?.textColor = .label

        let loggedIn = item.value(forKey: "loggedin") as? Bool
        
        if loggedIn == false {
          cell.loggedInLabel.text? = "0"
        } else {
            cell.loggedInLabel.text? = "1"
        }
        
        cell.photoURL?.text =  (item.value(forKey: "photoURL")! as! String)
        cell.photoURL?.textColor = .label
        
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
            
            let message = error.localizedDescription
            self.presentAlert(withTitle: NSLocalizedString("Error", comment: "ListTableViewController viewWillAppear"),
                              message: message)
        }
        activity.stopAnimating()
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Slett") { (action, sourceView, completionHandler) in

            let item = self.listItems[indexPath.row]
            let userEmail = item.value(forKey: "email") as? String

            if self.deleteUserCoreData(UserEmail: String(describing: userEmail!))  == true {
            } else {
                let message = NSLocalizedString("Unable to delete data in CoreData: ", comment: "ListTableViewController.swift trailingSwipeActionsConfigurationForRowAt ")
                    + userEmail!
                
                self.presentAlert(withTitle: NSLocalizedString("Error", comment: "ListTableViewController.swift SaveNewPassword "),
                                  message: message)
            }

           // Call completion handler with true to indicate
            completionHandler(true)
        }
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        
        return swipeConfiguration
    }
    
}
