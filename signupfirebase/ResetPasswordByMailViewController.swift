//
//  UpdatePasswordByMailViewController.swift
//  signupfirebase
//
//  Created by Jan  on 22/11/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

import UIKit
import Firebase

class ResetPasswordByMailViewController: UIViewController, UITextFieldDelegate { 

    @IBOutlet weak var SendEmailToReceiver: UITextField!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    var myTimer: Timer!
    
    // Setter en "constant" forsinkelse etter at en trykker på "Save"
    let forsinkelse = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SendEmailToReceiver.delegate = self
    
        activity.hidesWhenStopped = true
        self.activity.style = .gray
        view.addSubview(activity)
    
        self.activity.startAnimating()
    
        Auth.auth().signIn(withEmail: ePost, password: passOrd) { (user, error) in
    
            if error == nil {
    
                // Setter inn epost som det skal sendes til
                let user = Auth.auth().currentUser
    
                if user != nil {
                    self.SendEmailToReceiver.text = user!.email
                } else {
                    // Håndtere error
                    self.presentAlert(withTitle: "Error", message: error?.localizedDescription as Any)
                }
    
            }
        }
        
        self.activity.stopAnimating()
        
    }
    
    @IBAction func SendPasswordResetByMail(_ sender: UIBarButtonItem) {

        //    Auth.auth().languageCode = "fr"
        //    // To apply the default app language instead of explicitly setting it.
        //    Auth.auth().useAppLanguage()

        Auth.auth().languageCode = "no"
        Auth.auth().sendPasswordReset(withEmail: SendEmailToReceiver.text!) { (error) in
            if error == nil {
                
                
//                noreply@signupfirebase-236b9.firebaseapp.com
//                Tilbakestill passordet ditt for project-211156156416
//                Til: Jan Hovland <jan.hovland@lyse.net>
//
//
//                Hei!
//
//                Følg denne linken for å tilbakestille passordet ditt for project-211156156416 for jan.hovland@lyse.net-kontoen din.
//
//                https://signupfirebase-236b9.firebaseapp.com/__/auth/action?mode=resetPassword&oobCode=cbM_F1SDClyXPTcM3Q0O0YFmgqi8luQ_WopFeulUubwAAAFnPQpx6g&apiKey=AIzaSyDw7qNj9OPW9NUH5TWva1z8mwbYpSNUdC4&lang=no
//
//                Hvis du ikke har bedt om å tilbakestille passordet, kan du ignorere denne e-posten.
//
//                Vennlig hilsen
//
//                project-211156156416-teamet
    
            } else {
                self.presentAlert(withTitle: "Error", message: error?.localizedDescription as Any)
            }

        }
    }

    @objc func returnToLogin() {
        performSegue(withIdentifier: "BackToLoginViewController", sender: self)
        myTimer.invalidate()
        print(ePost)
    }

}
