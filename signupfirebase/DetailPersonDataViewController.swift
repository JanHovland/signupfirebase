//
//  DetailPersonDataViewController.swift
//  signupfirebase
//
//  Created by Jan  on 13/01/2019.
//  Copyright © 2019 Jan . All rights reserved.
//

import UIKit

class DetailPersonDataViewController: UIViewController {
    @IBOutlet var userInfo: UILabel!

    var detailPersonNameText = ""
    var detailPersonAddressText = ""
    var detailPersonDateOfBirthText = ""
    var detailPersonGenderInt = 0

    @IBOutlet var detailPersonName: UITextField!
    @IBOutlet var datailPersonAddress: UITextField!
    @IBOutlet var detailPersonDateOfBirth: UITextField!
    @IBOutlet var detailPersonGender: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        userInfo.text = showUserInfo(startUp: false)

        detailPersonName.text = detailPersonNameText
        datailPersonAddress.text = detailPersonAddressText
        detailPersonDateOfBirth.text = detailPersonDateOfBirthText
        
        // Indicates selected gender
        detailPersonGender.selectedSegmentIndex = detailPersonGenderInt

        if detailPersonGenderInt == 0 {
            detailPersonGender.setTitle(NSLocalizedString("Man", comment: "DetailPersonDataViewController viewDidAppear "),
                                        forSegmentAt: detailPersonGenderInt)
        } else {
            detailPersonGender.setTitle(NSLocalizedString("Woman", comment: "DetailPersonDataViewController viewDidAppear "),
                                        forSegmentAt: detailPersonGenderInt)
        }

    }
}
