//
//  BirthdayViewController.swift
//  signupfirebase
//
//  Created by Jan Hovland on 27/04/2019.
//  Copyright © 2019 Jan . All rights reserved.
//

import UIKit
import UserNotifications

class BirthdayNotificationViewController: UIViewController {
    
    @IBOutlet var infoTextView: UITextView!
    var status: Bool = true
    
    let identifier = "birthDay"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        infoTextView.isHidden = true
        
        // Set up didEnterBackgroundNotification which is called when the app is set to background
        NotificationCenter.default.addObserver(self, selector: #selector(pauseWhenBackground(noti:)), name: UIApplication.didEnterBackgroundNotification, object: nil)

        let melding1 = NSLocalizedString("Local notification can only execute when the app is set to background.",
                                         comment: "BirthdayNotificationViewController.swift viewDidLoad ")
        
        let melding2 = NSLocalizedString("The notification will start when you press the 'Home' button.",
                                         comment: "BirthdayNotificationViewController.swift viewDidLoad ")
        
        let melding3 = NSLocalizedString("NB. The app will only produce one notification. It will not repeat itself.",
                                         comment: "BirthdayNotificationViewController.swift viewDidLoad ")
        
        infoTextView.text = melding1 + "\n\n" + melding2 + "\n\n" + melding3

    }
    
    @IBAction func info(_ sender: Any) {
        status = !status
        infoTextView.isHidden = status
    }

    @objc func pauseWhenBackground(noti: Notification) {
        findBirthdaysThisMonth()
    }
    
    @objc func findBirthdaysThisMonth() {
        
        var title: String = ""
        var body: String = ""
        var str1: String = ""
        var str2: String = ""
        var str3: String = ""
        var str4: String = ""
        var monthTodayString: String = ""
        var teller: Int = 0
        
        // Read all persons from Firebase
        DispatchQueue.global(qos: .userInteractive).async {
            self.makeReadPersons()
        }
        
        // Sort by dateOfBirth2 ("04-21" = 21. april)
        persons.sort(by: {$0.personData.dateOfBirth2 < $1.personData.dateOfBirth2})
        
        // Find today's month
        let date = Date()
        let calendar = Calendar.current
        let todaysMonth = calendar.component(.month, from: date)
        
        str1 = "\(todaysMonth)"
        
        if str1.count == 1 {
            monthTodayString = "0" + str1
        } else {
            monthTodayString = str1
        }
        
        // Set default values
        
        title = NSLocalizedString("No birthdays in this month", comment: "BirthdayNotificationViewController.swift findBirthdaysThisMonth")
        body = ""
       
        if persons.count > 0 {
        
            let max = persons.count - 1
            
            for n in 0...max {
                
                str3 = persons[n].personData.dateOfBirth2
                
                if let separator = str3.firstIndex(of: "-") {
                    let monthFromPerson = str3[..<separator]
                    
                    if monthFromPerson == monthTodayString {
                        
                        switch monthTodayString  {
                            case "01":
                                str2 = NSLocalizedString("january", comment: "BirthdayNotificationViewController.swift findBirthdaysThisMonth")
                            case "02":
                                str2 = NSLocalizedString("february", comment: "BirthdayNotificationViewController.swift findBirthdaysThisMonth")
                            case "03":
                                str2 = NSLocalizedString("march", comment: "BirthdayNotificationViewController.swift findBirthdaysThisMonth")
                            case "04":
                                str2 = NSLocalizedString("april", comment: "BirthdayNotificationViewController.swift findBirthdaysThisMonth")
                            case "05":
                                str2 = NSLocalizedString("may", comment: "BirthdayNotificationViewController.swift findBirthdaysThisMonth")
                            case "06":
                                str2 = NSLocalizedString("june", comment: "BirthdayNotificationViewController.swift findBirthdaysThisMonth")
                            case "07":
                                str2 = NSLocalizedString("july", comment: "BirthdayNotificationViewController.swift findBirthdaysThisMonth")
                            case "08":
                                str2 = NSLocalizedString("august", comment: "BirthdayNotificationViewController.swift findBirthdaysThisMonth")
                            case "09":
                                str2 = NSLocalizedString("september", comment: "BirthdayNotificationViewController.swift findBirthdaysThisMonth")
                            case "10":
                                str2 = NSLocalizedString("october", comment: "BirthdayNotificationViewController.swift findBirthdaysThisMonth")
                            case  "11":
                                str2 = NSLocalizedString("november", comment: "BirthdayNotificationViewController.swift findBirthdaysThisMonth")
                            case  "12":
                                str2 = NSLocalizedString("december", comment: "BirthdayNotificationViewController.swift findBirthdaysThisMonth")
                            default :
                                str2 = ""
                        }
                        
                        print(str2)
                        
                        
                        teller += 1
                        
                        if teller == 1 {
                            title = NSLocalizedString("Birthday in ", comment: "BirthdayNotificationViewController.swift findBirthdaysThisMonth") + str2
                        } else {
                            title = NSLocalizedString("Birthdays in ", comment: "BirthdayNotificationViewController.swift findBirthdaysThisMonth") + str2
                        }
                            
                        if let secondSpace = persons[n].personData.dateOfBirth1.lastIndex(of: " ") {
                            str4 = String(persons[n].personData.dateOfBirth1[..<secondSpace])
                            body = body +  str4 + " " + persons[n].personData.firstName + "\n"
                        }
                        
                    }
                }
                
            }
            
        }
        
        // Shows max 2 lines on Banner and  max 4 lines on Notificartion Center
        // let body = "11. mai Julie " + "\n" + "20.mai Ågot1 " + "\n" + "20.mai Ågot2 " + "\n" + "20.mai Ågot3 "
        
        // #1.1 - Create "the notification's category value--its type."
        let birthdayNotifCategory = UNNotificationCategory(identifier: identifier, actions: [], intentIdentifiers: [], options: [])
        // #1.2 - Register the notification type.
        UNUserNotificationCenter.current().setNotificationCategories([birthdayNotifCategory])
        
        sendNotification(title: title,
                         body: body)
        
    }
    
    func sendNotification(title: String,
                          body: String) {
        
        // find out what are the user's notification preferences
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            
            // we're only going to create and schedule a notification
            // if the user has kept notifications authorized for this app
            guard settings.authorizationStatus == .authorized else { return }
            
            // create the content and style for the local notification
            let content = UNMutableNotificationContent()
            
            // #2.1 - "Assign a value to this property that matches the identifier
            // property of one of the UNNotificationCategory objects you
            // previously registered with your app."
            content.categoryIdentifier = self.identifier
            content.title = title
            content.body = body
            content.sound = UNNotificationSound.default
            
            // #2.2 - create a "trigger condition that causes a notification
            // to be delivered after the specified amount of time elapses";
            // deliver after 10 seconds
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            // create a "request to schedule a local notification, which
            // includes the content of the notification and the trigger conditions for delivery"
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
            
            // "Upon calling this method, the system begins tracking the
            // trigger conditions associated with your request. When the
            // trigger condition is met, the system delivers your notification."
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            
        } // end getNotificationSettings
        
    } // end func sendNotification

}
