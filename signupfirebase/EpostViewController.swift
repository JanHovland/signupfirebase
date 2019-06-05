//
//  EpostViewController.swift
//  signupfirebase
//
//  Created by Jan Hovland on 24/03/2019.
//  Copyright © 2019 Jan . All rights reserved.
//

import UIKit
import MessageUI

class EpostViewController: UIViewController {
    
    var subject = ""
    var toRecipients = ""
    var messageBody = ""
    
    var mailInfo = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showMailComposer()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func showMailComposer() {
        
        // You should call this method before attempting to display the mail composition interface. If it returns false, you must not display the mail composition interface.
        
        guard MFMailComposeViewController.canSendMail() else {
            //Show alert informing the user
            let string = NSLocalizedString("This device is not configured to send email.", comment: "EpostViewController.swift EpostViewController")
            self.presentAlert(withTitle: NSLocalizedString("Error", comment: "EpostViewController.swift EpostViewController"),
                              message: string)
            return
        }
        
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        
        // Sets the initial text for the subject line of the email.
        composer.setSubject(subject)
        
        // Sets the initial recipients to include in the email’s “To” field.
        composer.setToRecipients([toRecipients])
        
        // Sets the initial recipients to include in the email’s “Cc” field.
        composer.setCcRecipients([""])
        
        // Sets the initial recipients to include in the email’s “Bcc” field.
        composer.setBccRecipients([""])
        
        // Sets the initial body text to include in the email.
        composer.setMessageBody(messageBody, isHTML: false)
        
        present(composer, animated: true)
    }
}


extension EpostViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        var message = ""
        
        if let _ = error {
            //Show error alert
            controller.dismiss(animated: true)
            return
        }
 
        switch result {
        case .cancelled:
            message = "Cancelled"
        case .failed:
            message = "Failed to send"
        case .saved:
            message = "Saved"
        case .sent:
            message = "Email Sent"
        @unknown default:
            message = "Unknown"
        }
        
        print(message)

        if mailInfo.count == 0 {
            performSegue(withIdentifier: "gotoMainPerson", sender: self)
        } else if mailInfo.count > 0 {
            performSegue(withIdentifier: "goBackToSettings", sender: self)
        }
        
        dismiss(animated: true, completion: nil)

    }
}
