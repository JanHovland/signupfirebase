//
//  SavePostalCodesFirebaseTableViewController.swift
//  signupfirebase
//
//  Created by Jan  on 31/01/2019.
//  Copyright © 2019 Jan . All rights reserved.
//

import UIKit
import MobileCoreServices

class SavePostalCodesFirebaseTableViewController: UITableViewController, UIDocumentPickerDelegate {

    @IBOutlet weak var switchStorePostalCodes: UISwitch!
    
    @IBOutlet weak var userInfo: UILabel!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    @IBOutlet weak var readString: UITextView!
    
    var inputString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activity.hidesWhenStopped = true
        activity.style = .gray
        view.addSubview(activity)
        
        // Set the 'switchStorePostalCodes' to inaktive
        UserDefaults.standard.set(false, forKey: "SHOWSTOREPOSTALCODES")
        switchStorePostalCodes.isOn = false
        
    }

    override func viewDidAppear(_ animated: Bool) {
        userInfo.text = showUserInfo(startUp: false)
    }
    
    @IBAction func showStorePostalCodes(_ sender: Any) {
        if (UserDefaults.standard.bool(forKey: "SHOWSTOREPOSTALCODES")) == true {
            UserDefaults.standard.set(false, forKey: "SHOWSTOREPOSTALCODES")
            switchStorePostalCodes.isOn = false
        } else {
            UserDefaults.standard.set(true, forKey: "SHOWSTOREPOSTALCODES")
            switchStorePostalCodes.isOn = true
        }
    }
   
    @IBAction func StorePostalCodes(_ sender: UIBarButtonItem) {
        activity.startAnimating()
        
        if (UserDefaults.standard.bool(forKey: "SHOWSTOREPOSTALCODES")) == true {
        
            let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeCommaSeparatedText as String], in: .import)
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = false
            present(documentPicker, animated: true, completion: nil)
            
        } else {
            let melding = NSLocalizedString("In order to save the Postal Codes, the 'Store Postal Codes in Firebase' button must be enabled.",
                                            comment: "SavePostalCodesFirebaseTableViewController.swift StorePostalCodes")
            let melding1 = "\n" + melding
            self.presentAlert(withTitle: NSLocalizedString("Cannot store the Postal Codes in Firebase.",
                                                           comment: "SavePostalCodesFirebaseTableViewController.swift StorePostalCodes"),
                              message: melding1)
        }
        
        activity.stopAnimating()

        UserDefaults.standard.set(false, forKey: "SHOWSTOREPOSTALCODES")
        switchStorePostalCodes.isOn = false
        
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        guard let selectedFileURL = urls.first else {
            return
        }
        
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let sandboxFileURL = dir.appendingPathComponent(selectedFileURL.lastPathComponent)
        
        if FileManager.default.fileExists(atPath: sandboxFileURL.path) {
            print("Already exists! Do nothing")
        }
        else {
            
            do {
                try FileManager.default.copyItem(at: selectedFileURL, to: sandboxFileURL)
                
                print("Copied file!")
            }
            catch {
                print("Error: \(error)")
            }
        }
        
        // Read content of the file
        
        do {
            inputString = try String(contentsOf: sandboxFileURL)
            print(inputString as Any)
            
        } catch let error as NSError {
            print("Failed to read file")
            print(error)
        }
        
        print("Contents of this file: \(inputString)")
        
        readString.text = inputString
        
        
        // Save postalcodes in Firebase
        
        // savePostalCodesFiredata(postnummer: "0001",
        //                         poststed: "Oslo")

        // Load the CSV readString and parse it
        
        
        //        Postnummer;Poststed;Kommunenummer;Kommunenavn;Kategori
        //        0001;OSLO;0301;OSLO;P
        //
        
        let delimiter = ";"
        var items:[(Postnummer:String, Poststed:String, Kommunenummer: String, Kommunenavn: String, Kategori: String)]?
        
        
        do {
            let content = try String(contentsOf: sandboxFileURL)
            items = []
            let lines: [String] = content.components(separatedBy: .newlines)
            
            for line in lines {
                var values:[String] = []
                if line != "" {
                    // For a line with double quotes
                    // we use NSScanner to perform the parsing
                    if line.range(of: "\"") != nil {
//                        var textToScan:String = line
//                        var value:NSString?
//                        var textScanner:Scanner = Scanner(string: textToScan)
//                        while textScanner.string != "" {
//                            
//                            if (textScanner.string as NSString).substring(to: 1) == "\"" {
//                                textScanner.scanLocation += 1
//                                textScanner.scanUpTo("\"", into: &value)
//                                textScanner.scanLocation += 1
//                            } else {
//                                textScanner.scanUpTo(delimiter, into: &value)
//                            }
//                            
//                            // Store the value into the values array
//                            if let value = value {
//                                values.append(value as String)
//                            }
//                            
//                            // Retrieve the unscanned remainder of the string
//                            if textScanner.scanLocation < textScanner.string.count {
//                                textToScan = (textScanner.string as NSString).substring(from: textScanner.scanLocation + 1)
//                            } else {
//                                textToScan = ""
//                            }
//                            textScanner = Scanner(string: textToScan)
//                        }
//                        
                        // For a line without double quotes, we can simply separate the string
                        // by using the delimiter (e.g. comma)
                    } else  {
                        values = line.components(separatedBy: delimiter)
                    }
                    
                    // Put the values into the tuple and add it to the items array
                    let item = (Postnummer: values[0], Poststed: values[1], Kommunenummer: values[2], Kommunenavn: values[3], Kategori: values[4])
                    
                    print(item.Postnummer + " " + item.Poststed)
                    
                    items?.append(item)
                }
            }
            
        } catch {
            print(error)
        }
        
        
        
        
        
        
    }

    
    
}
