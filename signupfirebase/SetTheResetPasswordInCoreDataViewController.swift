//
//  SetTheResetPasswordInCoreDataViewController.swift
//  signupfirebase
//
//  Created by Jan  on 30/11/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import Firebase
import UIKit

class SetTheResetPasswordInCoreDataViewController: UIViewController {
    var myTimer: Timer!

    @IBOutlet var activity: UIActivityIndicatorView!
    @IBOutlet var ResetPassword: UITextField!

    // Setter en "constant" forsinkelse etter at en trykker på "Save"
    let forsinkelse = 3

    override func viewDidLoad() {
        super.viewDidLoad()
        
        activity.hidesWhenStopped = true
        activity.style = .gray
        view.addSubview(activity)
        
    }

    @IBAction func ResetPasswordInCoreData(_ sender: UIBarButtonItem) {
        if ResetPassword.text!.count > 0 {
            activity.startAnimating()

            // Oppdaterer passordet i CoreData
            let ok = updatePasswordCoreData(withEpost: (Auth.auth().currentUser?.email!)!,
                                            withPassWord: ResetPassword.text!)

            if ok == false {
                presentAlert(withTitle: "Feil", message: "Kan ikke oppdatere passordet til brukeren i CoreData.")
            }

            // Legg inn en liten forsinkelse før funksjonen "returnToLogin" kalles
            myTimer = Timer.scheduledTimer(timeInterval: TimeInterval(forsinkelse),
                                           target: self,
                                           selector: #selector(returnToLogin),
                                           userInfo: nil,
                                           repeats: false)
            activity.stopAnimating()
        } else {
        }
    }

    @objc func returnToLogin() {
        performSegue(withIdentifier: "BackToLoginViewControllerFromResetPasswordInCoreDara", sender: self)
        myTimer.invalidate()
    }
}
