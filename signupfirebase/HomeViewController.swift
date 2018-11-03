//
//  HomeViewController.swift
//  signupfirebase
//
//  Created by Jan  on 03/11/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func cancelPost(_ sender: Any) {
        
        // Dismiss the popover
        presentingViewController?.dismiss(animated: true, completion: nil)
        
        
    }

}
