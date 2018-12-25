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
        
        // Test av lagring av data i Firedata
//        SavePostFiredata(uid: "567890",
//                         username: "Jan Hovland",
//                         photoURL: "google.no",
//                         text: "Dette er en test av 3. lagring")
        
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
        cell?.detailTextLabel?.text = posts[indexPath.row].id
        
        return cell!

    }
    
    func ReadPostFiredata() {
        let postsRef = Database.database().reference().child("posts")
        
        postsRef.observe(.value, with: { snapshot in
            
            var tempPosts = [Post]()
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                    let dict = childSnapshot.value as? [String:Any],
                    let author = dict["author"] as? [String:Any],
                    let uid = author["uid"] as? String,
                    let username = author["username"] as? String,
                    let photoURL = author["photoURL"] as? String,
                    let url = URL(string:photoURL),
                    let text = dict["text"] as? String,
                    let timestamp = dict["timestamp"] as? Double {
                    
                    let userProfile = UserProfile(uid: uid, username: username, photoURL: url)
                    let post = Post(id: childSnapshot.key, author: userProfile, text: text, timestamp:timestamp)
                    tempPosts.append(post)
                    
                }
                
            }
            
            self.posts = tempPosts
            // Fyller ut table view
            self.tableView.reloadData()
            

        })
    }

}


