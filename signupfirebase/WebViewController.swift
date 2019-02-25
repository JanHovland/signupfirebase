//
//  WebViewController.swift
//  signupfirebase
//
//  Created by Jan Hovland on 25/02/2019.
//  Copyright © 2019 Jan . All rights reserved.
//

import UIKit
import SafariServices


class WebViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never

        let link = "https://console.firebase.google.com"
        
        if let url = URL(string: link) {
            UIApplication.shared.open(url)
        }
        
    }
    
}
