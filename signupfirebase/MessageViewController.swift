//
//  MessageViewController.swift
//  signupfirebase
//
//  Created by Jan Hovland on 24/03/2019.
//  Copyright © 2019 Jan . All rights reserved.
//

import UIKit
import MessageUI

class MessageViewController: UIViewController,  MFMessageComposeViewControllerDelegate {

    
    // Values are set in MainPersonDataTableViewController.ewift or BirthdayTableViewController.swift
    var messagePhoneNumber: String = ""
    var messageBody: String = ""
    var messageId: String = ""             // "fromMainPersonData" or "fromBirthday"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let messageVC = MFMessageComposeViewController()
        
        messageVC.messageComposeDelegate = true as? MFMessageComposeViewControllerDelegate
        
        messageVC.body = messageBody
        messageVC.recipients = [messagePhoneNumber]
        messageVC.messageComposeDelegate = self
        
        self.present(messageVC, animated: true, completion: nil)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result) {
        case .cancelled:
            print("Message was cancelled")
            if messageId == "fromMainPersonData" {
                performSegue(withIdentifier: "goBackToPersondata", sender: self)
            } else if messageId == "fromBirthday" {
                performSegue(withIdentifier: "goBackToBirthday", sender: self)
            }
            dismiss(animated: true, completion: nil)
        case .failed:
            print("Message failed")
            if messageId == "fromMainPersonData" {
                performSegue(withIdentifier: "goBackToPersondata", sender: self)
            } else if messageId == "fromBirthday" {
                performSegue(withIdentifier: "goBackToBirthday", sender: self)
            }
            dismiss(animated: true, completion: nil)
        case .sent:
            print("Message was sent")
            if messageId == "fromMainPersonData" {
                performSegue(withIdentifier: "goBackToPersondata", sender: self)
            } else if messageId == "fromBirthday" {
                performSegue(withIdentifier: "goBackToBirthday", sender: self)
            }
            dismiss(animated: true, completion: nil)
        default:
            break
        }
    }

}
