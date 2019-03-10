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
           b) "Lagre postnummer i Firebase"
        
        5. Real time databasen Firebase fra Google.
        
           a) Finnes på https://console.firebase.google.com
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
           e) Legge inn telefon nummer
              , Formattere -> 123 45 678
              . Oppdatere Firebase
              . Oppdatere Lagre, oppdatere, hente og slette i Firebase
           f) Endret høyden på scrollview Curriculum Vitae til 3000
           g) Ta bort avhukinger etter scroll utenfor view vha func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
              som kaller deleteAllCheckmarks()
           h) Sorterer begge array
              . self.persons.sort(by: {$0.personData.firstName < $1.personData.firstName})
              . postalCodes.sort(by: {$0.city < $1.city})
           i) Legge inn postnr og poststed inn i PersonViewController
              . Det er problemer med å bruke array, da compileren kun tillater opptil en viss størrelse.
                Legger nå ut postnummer inn i Firebase og leser derfra inn i postalCodes arrayet
              . https://www.bring.no/radgivning/sende-noe/adressetjenester/postnummer/
              . Hent .Excel format (xlsx)
              . Legg ut som .csv fil via Excel (Problemer med Tab-separerte felter (ANSI))
           j) Lese .csv filen med postnr og poststed inn i Firestore
           k) Har nå lagt postnummer inn i Firebase og leser derfra inn i postalCodes
           l) Bruker nå filter({$0.xxxxxxxxx.contains(searchText.uppercased())}) på begge arrayene. Poststed ligger som
              uppercase og brukes som uppercase. Dermed kan jeg finne alle poststedene som inneholder en søkestreng.
           m) Format av telefon er kommentert bort, må rettes og implementeres
              .Test OK
           n) Lagt inn nytt punkt "Lagre postnummer i Firebase" under "Innstillinger"
           o) Legge inn indexed table view for kunne søke raskere på Postnummer
           p) Legge inn Bilde i PersonViewController
           q) Benytte cache
           r) Løst problemene med "krølling av bilder"
              Løsning: if self.persons[indexPath.row].personData.photoURL == photoURL i MainPersonDataViewController.swift
           s) Søking på person er feil (krølling tekst)
              . Grunnen var at nameLabel manglet avhuking for "Clears Graphics Context"
                One example of when you might use it is if you have a label (clear background) and you're changing the text.
                Without this flag, the new text is drawn over the old text. With the box checked, the label area is "erased" before the next text is drawn.
           t) Lagt inn Kart i PersonViewController (uten å gå gjennom opsjonene)
           u) Lagt inn default bilde når en legger inn en ny person
        
        7. Nye oppgaver (ikke fullført)
        
           a) Velge automatisk innlogging i "Innstillinger"
           b) Legge inn default bilde (new-person) i oppstart
           c) Se igjennom opsjonene for Kart i PersonViewController
           d) Vise fremgang
           e) Oppdatere security i Firebase (er det samme for Firestore?)
        
        8. Programmerings tips
        
           a) SearchBar Xcode
              . Show Search Results Button
                .. searchBarResultsListButtonClicked()
              . Show Booksmark Button
                .. searchBarBookmarkButtonClicked()
              . Show Cancel Button
                .. searchBarCancelButtonClicked()
        
        9. Firestore
           a) Informasjon
              . https://firebase.google.com/docs/firestore/data-model
              . Har gode queriesProgrammerings oppgaver:
              . Søkefunksjon i Firestore i PersonViewController på både fornavn og/eller etternavn
        
        9. Feil som må rettes
        
           a) Det kan legges inn flere like poster når en legger inn en ny person
        
        """
        
    }
    
}
