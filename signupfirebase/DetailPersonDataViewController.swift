//
//  DetailPersonDataViewController.swift
//  signupfirebase
//
//  Created by Jan  on 13/01/2019.
//  Copyright © 2019 Jan . All rights reserved.
//

import UIKit

class DetailPersonDataViewController: UIViewController {

    @IBOutlet weak var userInfo: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
   
    override func viewDidAppear(_ animated: Bool) {
        userInfo.text = showUserInfo(startUp: false)
        
    }


}
