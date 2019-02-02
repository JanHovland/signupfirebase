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
    var inputString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // activity.hidesWhenStopped = true
        activity.isHidden = false
        activity.style = .gray
        activity.startAnimating()

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

        if (UserDefaults.standard.bool(forKey: "SHOWSTOREPOSTALCODES")) == true {

            activity.startAnimating()
            
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
        
        UserDefaults.standard.set(false, forKey: "SHOWSTOREPOSTALCODES")
        switchStorePostalCodes.isOn = false
        
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        guard let selectedFileURL = urls.first else {
            return
        }
        
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let sandboxFileURL = dir.appendingPathComponent(selectedFileURL.lastPathComponent)
        
        if !FileManager.default.fileExists(atPath: sandboxFileURL.path) {
            do {
                try FileManager.default.copyItem(at: selectedFileURL, to: sandboxFileURL)
            }
            catch {
                print("Error: \(error)")
            }
        }
        
        // Read content of the sandboxFileURL
        
        let delimiter = ";"
        
        do {
            let content = try String(contentsOf: sandboxFileURL)
            let lines: [String] = content.components(separatedBy: .newlines)
            
            for line in lines {
                var values:[String] = []
                if line != "" {
                    if line.range(of: "\"") != nil {
                    } else  {
                        values = line.components(separatedBy: delimiter)
                    }
                    
                    let item = (Postnummer: values[0], Poststed: values[1], Kommunenummer: values[2], Kommunenavn: values[3], Kategori: values[4])
                    
                    // Set "namecase" to item.Poststed
                    let poststed1 = item.Poststed.lowercased()
                    // capitalized : All word(s)' first letter will be uppercased()
                    let poststed2 = poststed1.capitalized
                    
                    //  Replace " I " with " i "
                    let poststed = poststed2.replacingOccurrences(of: " I ", with: " i ")
                    
                    // Set "namecase" to item.Kommune
                    let kommune1 = item.Kommunenavn.lowercased()
                    
                    // capitalized : All word(s)' first letter will be uppercased()
                    let kommune = kommune1.capitalized
                    
                    savePostalCodesFiredata(postnummer: item.Postnummer,
                                            poststed: poststed,
                                            kommunenummer: item.Kommunenummer,
                                            kommune: kommune)
                    
                }
            }
            
        } catch {
            print(error)
        }
        
        let title = NSLocalizedString("Save in Firebase",comment: "documentPicker.swift savePostalCodesFiredata")
        let message = "\r\n" + NSLocalizedString("Data are now saved in Firebase.", comment: "documentPicker.swift savePostalCodesFiredata")
        self.presentAlert(withTitle: title, message: message)
        
        activity.isHidden = true
        activity.stopAnimating()
        
    }
    
}
