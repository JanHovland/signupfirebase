//
//  MainPersonDataTableViewController.swift
//  signupfirebase
//
//  Created by Jan  on 23/12/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import UIKit
import CoreData
import FirebaseDatabase

class MainPersonDataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Henter pålogget bruker
        //  0 = uid  1 = ePost  2 = name  3 = passWord)
        let value = getCoreData()
        
        // Test av lagring av data i Firedata
        SavePostFiredata(uid: value.0,
                         username: value.2,
                         email: value.1,
                         text: "Dette er en test av 5. lagring")
        
        // Henter postene fra Firebase
        ReadPostFiredata()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Henter pålogget bruker
        //  0 = uid  1 = ePost  2 = name  3 = passWord)
        let value = getCoreData()
        
        // Test av lagring av data i Firedata
        SavePostFiredata(uid: value.0,
                         username: value.2,
                         email: value.1,
                         text: "Dette er en test av 6. lagring")
        
        // Henter postene fra Firebase
        ReadPostFiredata()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell")
        
        /*
         
         Standard table view cell:
         
            When using table view cell of type "Basic" :
            cell?.textLabel?.text          :  "returns the label used for the main textual content of the table cell"
         
         
            When using table view cell of type "Right detail", "Left detail" and "Subtitle :
            cell?.textLabel?.text          :  "returns the label used for the main textual content of the table cell"
            cell?.detailTextLabel?.text    :  "returns the secondary label of the table cell if one exists
        
         */
        
        cell?.textLabel?.text = posts[indexPath.row].text
        cell?.detailTextLabel?.text = posts[indexPath.row].author.username
        
        return cell!

    }
    
    func ReadPostFiredata() {
        let postsRef = Database.database().reference().child("posts")
        
        postsRef.observe(.value, with : { snapshot in
        
            var tempPosts = [Post]()
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                    let dict = childSnapshot.value as? [String:Any],
                    let author = dict["author"] as? [String:Any],
                    let uid = author["uid"] as? String,
                    let username = author["username"] as? String,
                    let email = author["email"] as? String,
                    let text = dict["text"] as? String,
                    let timestamp = dict["timestamp"] as? Double {
                    
                    let userProfile = UserProfile(uid: uid, username: username, email: email)
                    let post = Post(id: childSnapshot.key, author: userProfile, text: text, timestamp:timestamp)
                    
                    tempPosts.append(post)
                    
                }
                
            }
            
            // Oppdaterer posts array
            self.posts = tempPosts
            
            // Fyller ut table view
            self.tableView.reloadData()
            

        })
    }

}


