//
//  SavePostalCodesFirebaseTableViewController.swift
//  signupfirebase
//
//  Created by Jan  on 31/01/2019.
//  Copyright © 2019 Jan . All rights reserved.
//

import MobileCoreServices
import UIKit

class SavePostalCodesFirebaseTableViewController: UITableViewController, UIDocumentPickerDelegate {
    @IBOutlet var switchStorePostalCodes: UISwitch!

    @IBOutlet var userInfo: UILabel!

    @IBOutlet var activity: UIActivityIndicatorView!
    var inputString = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        activity.style = .gray
        activity.isHidden = true

        // Set the 'switchStorePostalCodes' to inaktive
        UserDefaults.standard.set(false, forKey: "SHOWSTOREPOSTALCODES")
        switchStorePostalCodes.isOn = false
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
            let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeCommaSeparatedText as String], in: .import)
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = false
            present(documentPicker, animated: true, completion: nil)

        } else {
            let message = NSLocalizedString("In order to save the Postal Codes, the 'Store Postal Codes in Firebase' button must be enabled.",comment: "SavePostalCodesFirebaseTableViewController.swift StorePostalCodes")
            let message1 = "\n" + message
            presentAlert(withTitle: NSLocalizedString("Cannot store the Postal Codes in Firebase.",
                                                      comment: "SavePostalCodesFirebaseTableViewController.swift StorePostalCodes"),
                         message: message1)
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
            } catch {
                let message = error.localizedDescription
                presentAlert(withTitle: NSLocalizedString("Error", comment: "SavePostalCodesFirebaseTableViewController.swift  documentPicker"),
                             message: message)
            }
        }

        activity.startAnimating()
        
        // Read content of the sandboxFileURL

        let delimiter = ";"

        do {
            let content = try String(contentsOf: sandboxFileURL)
            let lines: [String] = content.components(separatedBy: .newlines)

            for line in lines {
                var values: [String] = []
                if line != "" {
                    values = line.components(separatedBy: delimiter)

                    let item = (Postnummer: values[0], Poststed: values[1], Kommunenummer: values[2], Kommunenavn: values[3], Kategori: values[4])

                    if item.Postnummer != "Postnummer" {
                        savePostalCodesFiredata(postnummer: item.Postnummer,
                                                poststed: item.Poststed,
                                                kommunenummer: item.Kommunenummer,
                                                kommune: item.Kommunenavn)
                    }
                }
            }

        } catch {
            let message = error.localizedDescription
            presentAlert(withTitle: NSLocalizedString("Error", comment: "SavePostalCodesFirebaseTableViewController.swift  documentPicker"),
                         message: message)
        }

        let title = NSLocalizedString("Save in Firebase", comment: "SavePostalCodesFirebaseTableViewController.swift documentPicker")
        let message = "\r\n" + NSLocalizedString("Data are now saved in Firebase.", comment: "SavePostalCodesFirebaseTableViewController.swift documentPicker")
        presentAlert(withTitle: title, message: message)

        activity.isHidden = true
        activity.stopAnimating()
    }
}
