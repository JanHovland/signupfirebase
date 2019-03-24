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

    var messagePhoneNumber: String = ""
    var messageBody: String = ""
    
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
            performSegue(withIdentifier: "gotoMainPerson", sender: self)
            dismiss(animated: true, completion: nil)
        case .failed:
            print("Message failed")
            performSegue(withIdentifier: "gotoMainPerson", sender: self)
            dismiss(animated: true, completion: nil)
        case .sent:
            print("Message was sent")
            performSegue(withIdentifier: "gotoMainPerson", sender: self)
            dismiss(animated: true, completion: nil)
        default:
            break
        }
    }

}
