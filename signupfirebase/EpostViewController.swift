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

    @IBOutlet weak var subject: UITextField!
    @IBOutlet weak var body: UITextView!
    
    @IBAction func sendMail(_ sender: Any) {
        let picker = MFMailComposeViewController()
        picker.mailComposeDelegate = self
        
        if let subjectText = subject.text {
            picker.setSubject(subjectText)
        }
        picker.setMessageBody(body.text, isHTML: true)
        
        present(picker, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subject.delegate = self
        body.delegate = self
    }
    
    // MFMailComposeViewControllerDelegate
    
    // 1
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
    
    // UITextFieldDelegate
    
    // 2
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    // UITextViewDelegate
    
    // 3
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        body.text = textView.text
        
        if text == "\n" {
            textView.resignFirstResponder()
            
            return false
        }
        
        return true
    }
}
