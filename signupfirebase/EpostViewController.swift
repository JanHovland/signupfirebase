//
//  EpostViewController.swift
//  signupfirebase
//
//  Created by Jan Hovland on 24/03/2019.
//  Copyright © 2019 Jan . All rights reserved.
//

import UIKit
import MessageUI

class EpostViewController:  UIViewController, MFMailComposeViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var mailRecipients: UITextField!
    @IBOutlet weak var subject: UITextField!
    
    @IBOutlet weak var content: UITextView!
    
    let contentPlaceholder = NSLocalizedString("Write the content of the email", comment: "EpostViewController.swift definition")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mailRecipients.delegate = self
        subject.delegate = self
        content.delegate = self
        
        content.layer.borderWidth = 0.25
        content.layer.borderColor = UIColor.lightGray.cgColor
        
        content.text = contentPlaceholder
        content.textColor = UIColor.lightGray

    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if content.textColor == UIColor.lightGray {
            content.text = ""
            content.textColor = UIColor.black
        }
    }
    
    // Is this function necessary ?
    /*
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if content.text == "" {
            
            content.text = contentPlaceholder
            content.textColor = UIColor.lightGray
        }
    }
    */
    
    @IBAction func sendMail(_ sender: Any) {
        
        if mailRecipients.text!.count > 0,
           subject.text!.count > 0,
            content.text!.count > 0 {
            
            // showMailComposer()
            print("sendMail")
        } else {
            
            let melding = NSLocalizedString("All fields must be filled in.",
                                            comment: "EpostViewController.swift sendMail")
            
            self.presentAlert(withTitle: NSLocalizedString("Missing content of fields",
                                                           comment: "EpostViewController.swift sendMail"),
                              message: melding)
            
        }
            
    }
    
    func showMailComposer() {
        
        guard MFMailComposeViewController.canSendMail() else {
            //Show alert informing the user
            return
        }
        
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["jho.hovland@gmail.co"])
        composer.setSubject("HELP!")
        composer.setMessageBody("I love your videos, but... help!", isHTML: false)
        
        present(composer, animated: true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
