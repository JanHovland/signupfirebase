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

    @IBOutlet weak var recipients: UITextField!
    @IBOutlet weak var subject: UITextField!
    @IBOutlet weak var content: UITextView!
    
    var mailRecipients = ""
    var mailSubject = ""
    var mailContent = ""
    
    let contentPlaceholder = NSLocalizedString("Write the content of the email", comment: "EpostViewController.swift definition")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recipients.delegate = self
        subject.delegate = self
        content.delegate = self
        
        recipients.text! = mailRecipients
        subject.text! = mailSubject
        content.text! = mailContent
        
        content.layer.borderWidth = 0.25
        content.layer.borderColor = UIColor.lightGray.cgColor
        
        content.text = contentPlaceholder
        content.textColor = UIColor.lightGray
   
        if mailContent.count > 0 {
            content.text = mailContent
            content.textColor = UIColor.black
        }
        
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if content.textColor == UIColor.lightGray {
            
            if mailContent.count == 0 {
                content.text = ""
            }
            content.textColor = UIColor.black
        }
    }
 
    @IBAction func sendMail(_ sender: Any) {
        showMailComposer()
    }
    
    func showMailComposer() {
        
        guard MFMailComposeViewController.canSendMail() else {
            //Show alert informing the user
            return
        }
        
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients([recipients.text!])
        composer.setSubject(subject.text!)
        composer.setMessageBody(content.text!, isHTML: false)
        
        present(composer, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        var melding = ""
        
        if let _ = error {
            //Show error alert
            controller.dismiss(animated: true)
            return
        }
        
        switch result {
        case .cancelled:
            melding = NSLocalizedString("Cancelled", comment: "EpostViewController.swift mailComposeController")
        case .failed:
            melding = NSLocalizedString("Failed to send", comment: "EpostViewController.swift mailComposeController")
        case .saved:
            melding = NSLocalizedString("Saved", comment: "EpostViewController.swift mailComposeController")
        case .sent:
            melding = NSLocalizedString("Email Sent", comment: "EpostViewController.swift mailComposeController")
        @unknown default:
            melding = NSLocalizedString("Fatal error", comment: "EpostViewController.swift mailComposeController")
        }
        
        print(melding)
        
        controller.dismiss(animated: true)
        performSegue(withIdentifier: "gotoMainPerson", sender: self)
        dismiss(animated: true, completion: nil)
        
    }

}

