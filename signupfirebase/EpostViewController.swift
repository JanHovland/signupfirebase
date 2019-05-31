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
        
        if let _ = error {
            //Show error alert
            controller.dismiss(animated: true)
            return
        }
 
        switch result {
        case .cancelled:
            print("Cancelled")
        case .failed:
            print("Failed to send")
        case .saved:
            print("Saved")
        case .sent:
            print("Email Sent")
        @unknown default:
            print("unknown")
        }
        
        if mailInfo.count == 0, result == .cancelled {
            performSegue(withIdentifier: "gotoMainPerson", sender: self)
        } else if mailInfo.count > 0, result == .cancelled{
            performSegue(withIdentifier: "goBackToSettings", sender: self)
        }

        dismiss(animated: true, completion: nil)

    }
}




//class EpostViewController:  UIViewController, MFMailComposeViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
//
//    @IBOutlet weak var recipients: UITextField!
//    @IBOutlet weak var subject: UITextField!
//    @IBOutlet weak var messageBody: UITextView!
//
//    var mailRecipients = ""
//    var mailSubject = ""
//    var mailMessageBody = ""
//    var mailInfo = ""
//
//    let mailMessageBodyPlaceholder = NSLocalizedString("Write the content of the email", comment: "EpostViewController.swift definition")
//    let mailMessageSubjectPlaceholder = NSLocalizedString("Subject of the email", comment: "EpostViewController.swift definition")
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        recipients.delegate = self
//        subject.delegate = self
//        messageBody.delegate = self
//
//        recipients.text! = mailRecipients
//        subject.text! = mailSubject
//        messageBody.text! = mailMessageBody
//
//        messageBody.layer.borderWidth = 0.25
//        messageBody.layer.borderColor = UIColor.lightGray.cgColor
//
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//
//        if mailMessageBody.count > 0 {
//            messageBody.text = mailMessageBody
//            messageBody.textColor = UIColor.black
//        } else {
//            messageBody.text = mailMessageBodyPlaceholder
//            messageBody.textColor = UIColor.lightGray
//        }
//
//        if mailSubject.count > 0 {
//            subject.text = mailSubject
//            subject.textColor = UIColor.black
//        } else {
//            subject.text = mailMessageSubjectPlaceholder
//            subject.textColor = UIColor.lightGray
//        }
//
//    }
//
//    func textViewDidBeginEditing(_ textView: UITextView) {
//
//        if messageBody.textColor == UIColor.lightGray {
//
//            if mailMessageBody.count == 0 {
//                messageBody.text = ""
//            }
//            messageBody.textColor = UIColor.black
//        }
//    }
//
//    @IBAction func sendMail(_ sender: Any) {
//
//        // Prevents the placeholder to be exported
//        if messageBody.text == mailMessageBodyPlaceholder {
//            messageBody.text = ""
//        }
//
//        if subject.text == mailMessageSubjectPlaceholder {
//            subject.text = ""
//        }
//
//        showMailComposer()
//    }
//
//    func showMailComposer() {
//
//        guard MFMailComposeViewController.canSendMail() else {
//            //Show alert informing the user
//            return
//        }
//
//        let composer = MFMailComposeViewController()
//        composer.mailComposeDelegate = self
//        composer.setToRecipients([recipients.text!])
//        composer.setSubject(subject.text!)
//        composer.setMessageBody(messageBody.text!, isHTML: false)
//
//        present(composer, animated: true)
//    }
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
//
//    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
//
//        var melding = ""
//
//        if let _ = error {
//            //Show error alert
//            controller.dismiss(animated: true)
//            return
//        }
//
//        switch result {
//        case .cancelled:
//            melding = NSLocalizedString("Cancelled", comment: "EpostViewController.swift mailComposeController")
//        case .failed:
//            melding = NSLocalizedString("Failed to send", comment: "EpostViewController.swift mailComposeController")
//        case .saved:
//            melding = NSLocalizedString("Saved", comment: "EpostViewController.swift mailComposeController")
//        case .sent:
//            melding = NSLocalizedString("Email Sent", comment: "EpostViewController.swift mailComposeController")
//        @unknown default:
//            melding = NSLocalizedString("Fatal error", comment: "EpostViewController.swift mailComposeController")
//        }
//
//        print(melding)
//
//        controller.dismiss(animated: true)
//        if mailInfo.count == 0 {
//            performSegue(withIdentifier: "gotoMainPerson", sender: self)
//        } else {
//            performSegue(withIdentifier: "goBackToSettings", sender: self)
//        }
//
//        dismiss(animated: true, completion: nil)
//
//    }
//
// }

