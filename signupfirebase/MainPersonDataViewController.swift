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

class MainPersonDataViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Test av lagring av data i Firedata
        SavePostFiredata(uid: "12345",
                         username: "Jan Hovland",
                         photoURL: "google.no",
                         text: "Dette er en test")
    }


}


