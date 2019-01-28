//
//  CvViewController.swift
//  signupfirebase
//
//  Created by Jan  on 22/12/2018.
//  Copyright © 2018 Jan . All rights reserved.
//

/*
    To set up ScrollView correctly, see YouTube:
    Create a UIScrollView using Auto Layout in Storyboard for Xcode 9
    Paul Solt
*/

import UIKit

class CvViewController: UIViewController {

    @IBOutlet weak var cvTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        cvTextView.text =
            
        """
        
        Programmerings oppgaver:
        
        1. Xcode.
        
           a) Opprette lisens hos Apple
           b) Bruke Xcode miljøet til å lage apper
           c) ViewController
           d) TableViewController
           e) TableViewCell
           f) ScrollView
           g) Keyboard i mobilen
           h) Localization via nb.xcloc (nb = norsk versjon)
           i) SwipeTrailing og SwipeLeading
              . "Height" på  View må være > 90 for å kunne legge inn både tekst og icon
              . Bruk imageLiteral for å finne en icon
              . Bruk colorLiteral for å finne en farge
              . Bilde størrelse 35 x 35 bilde punkter ser OK ut
          j) Kjente feil:
             . Dersom en endrer på en label i en viewCell, sjekk at den gamle ikke ligger igjen i Main.storyboard
        
        2. Xcode editor
        
           a) trykk alt + return for å legge inn linjeskift i et textField
        
        2. Swift.
        
           a) Bruke Swift som programmeringsspråk.
           b) Bruke debugger
        
        3. GitHub.
        
           a) Lagre via menypunktet Source Control/Commit
           b) Hente: https://github.com/JanHovland
        
        3. CoreData.
        
           a) Oppdatere AppDelegate slik at directory vises i AppDelegate.swift
           b) Viser data med hjelp av applikasjonen "Datum"
           c) Bruke "Datum" for finne resultatet i CoreData av:
              . Insert data
              . Delete data
              . Update data
        
        4. UserDefault lagrer brukerspesifikke verdier.
        
           a) "Show Password"
        
        5. Real time databasen Firebase fra Google.
        
           a) Finnes på https://console.firebase.google.com/project/signupfirebase-236b9/database/firestore/data~2Fhttps://console.firebase.google.com/project/signupfirebase-236b9/database/firestore/data~2F
           b) Bruke Authentication i Firebase
              . Benytter epost og passord for pålogging
           c) Bruke Firebase databasen for:
              . Insert data
              . Delete data
             . Update data
           d) Autensiering:
             . epost
             . passord
        
        6. Endringer
        
           a) Update i Firebase
              . Via swipeLeading ved indirekte segue to PersonViewController
              . Via direkte segue to PersonViewController
           b) Delete i Forebase
              . via swipeTrailing
           c) Sette dateValg.date = PersonDateOfBirthTextslik at riktig dateValg vises
           d) Søkefunksjon i PersonViewController (må nå søke på hele navnet)
           e) Erstatte Navn med Fornavn og Etternavn i view
              . Oppdatere Firebase
              . Oppdatere Lagre, oppdatere, hente og slette i Firebase
           f) Legge inn telefon nummer
              , Formattere -> 123 45 678
              . Oppdatere Firebase
              . Oppdatere Lagre, oppdatere, hente og slette i Firebase
           h) Søkefunksjon i PersonViewController (kan kun søke på fornavn)
           i) Endret høyden på scrollview Curriculum Vitae til 3000
           j) Ta bort avhukinger etter scroll utenfor view vha func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
              som kaller deleteAllCheckmarks()
           k) Sorterer begge array
              . self.persons.sort(by: {$0.personData.firstName < $1.personData.firstName})
              . postalCodes.sort(by: {$0.city < $1.city})
        
        7. Nye oppgaver (ikke fullført)
        
           a) Legge inn postnr og poststed inn i PersonViewController
              . Det er problemer med å bruke array, da compileren kun tillater opptil en viss størrelse
              . https://www.bring.no/radgivning/sende-noe/adressetjenester/postnummer/
              . Hent .Excel format (xlsx)
              . Legg ut som .csv fil via Excel (Problemer med Tab-separerte felter (ANSI))
              . Lese .csv og legg inn i CoreData (Firebase)
              . Eventuelt legge disse inn i et array for raskt søk uten hjelp av database
           b) Søkefunksjon i PersonViewController (kan søke på fornavn, både for- og etternavn)
           c) Legge inn Bilde i PersonViewController
           d) Legge inn Kart i PersonViewController
           e) Oppdatere security i Firebase
           f) Firestore
              . https://firebase.google.com/docs/firestore/data-model
              . Har gode queriesProgrammerings oppgaver:
        
        8. Programmerings tips
        
           a) SearchBar Xcode
              . Show Search Results Button
                .. searchBarResultsListButtonClicked()
              . Show Booksmark Button
                .. searchBarBookmarkButtonClicked()
              . Show Cancel Button
                .. searchBarCancelButtonClicked()
           b)
        
        9. Feil som må rettes
        
           a) Format av telefon er kommentert bort, må rettes og implementeres
           b) OK Update: visningen krøller seg til
                 . Dette skyldes sammenslåing av firstName og lastName, forsvant da jeg splittet til 2 labels
                   Kan være at den labelName skulle vært satt til "" for nye data leses inn
           c) Det kan legges inn flere like poster
        
        
        
        """
        
    }
    
}
