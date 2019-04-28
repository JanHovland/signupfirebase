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
        
        3. Core Data.
        
           a) Oppdatere AppDelegate slik at directory vises i AppDelegate.swift
           b) Viser data med hjelp av applikasjonen "Datum"
           c) Bruke "Datum" for finne resultatet i Core Data av:
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
           o) Legge inn "indexed table view" for kunne søke raskere på Postnummer
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
           v) Skjuler tabBarController?.tabBar når den er aktiv, og du endrer på ePost feltet eller Passord feltet.
           w) Create new account: Legge inn default bilde (new-person) i oppstart
           x) Ta bort kamera icon og trykk på bildet for å bytte bilde.
              . LoginViewController.swift
              . CreateAccountViewController.swift
              . PersonViewController.swift
           y) Flyttet map icon til PersonViewController.swift
           z) Lagt inn "indexed table view" for kunne søke raskere på Persondata
           A) Når en starter PersonData vises ikke alle bildene (blir oppdatert når en velger en person for oppdatering og så går tilbake).
              Løst ved å benytte UIRefreshControl()
           B) Kan nå slette person i "indexed table view" korrekt.
           C) Tatt bort "Vennligst logg inn på Firebase" unntatt på log inn bildet.
           D) Viser nå "loggedin" i ListTableViewController.
           E) Viser nå korrekt keyboard i CreateAccountViewController.
           F) Oppdatere activity indicator i:
              . LoginViewController
              . CreateAccountViewController
              . UpdateUserNameViewController
              . UpdatePasswordViewController
              . ResetPWByMailViewController
              . PersonViewController
           G) Nå kommer riktig person ut på map, telefon og melding.
           H) Nå viser passordet avhengig av status på "Vis passord" i Instillinger
           I) Endret på layout for "Instillinger"
           J) Tatt bort makering av den cellen som ble valgt, spesielt "Vis passord" (Innstillinger)
           K) Oppdatert sending av melding. Returnerer nå direkte til det bilde som meldingen ble startet fra.
           L) Lagt inn for- og etternavn i tillegg til navn i Person.
           M) Lagt inn epost i Person.
           N) Nå oppdateres "Kjønn" riktig etter retur fra søking etter poststed (kun ved "Ny Person").
           O) Kan nå sende e-post fra MainPersonDataViewController
           P) Lagt inn "Send epost" i "Innstillinger"
           Q) Oppdatert innloggingsbildet slik at det er OK både med og uten brukere i Core Data.
           R) Lagt inn feilkoder for Firebase / Firestore
           S) Core Data oppdateres nå når en ny bruker logger inn og ved endring av bildet til brukeren.
           T) Nå trenger en ikke å logge inn etter å ha endret bildet til en bruker.
           U) Endret "List all users in Core Data til "Show Core Data"
           V) Viser photoURL i "Show Core Data"
           W) Overstyrer koordinatene for "Johanne Kristine Lima". Hun bor på Flå, men vises på Gol (annen person?)
           X) Har sett på oppdateringen av Persondata (må kjøre oppfrisking for å fåmed bildene). Foreslår å ikke gjøre noe.
           Y) Bildene i Persondata vises nå korrekt. Grunnen var en test på to URL's som sammenlignet to forskjellige URL's
           Z) Har tilpasset visningen kan gjøres raskere med background thread.
              "Introduction to iOS Threading - Zelda App (Xcode 8, Swift 3)" på Youtube.com av Mark Moeykens
               let start = Date()
               DispatchQueue.global(qos: .userInteractive).async {
                   self.makeRead()
               }
               DispatchQueue.global(qos: .userInteractive).async {
                   self.FindSearchedPersonData(searchText: "")
               }
               let end = Date()
               print = end.timeIntervalSince(start))

        7. Nye oppgaver (ikke fullført)
        
           . Legge inn 2 nye punkter under "Settings" :
             . "Oversikt fødselsdager" ("Overview birthdays")                      --> "BirthdaysTableviewController.swift" + "BirthdaysTableviewCell.swift"
               . "Dato" - "Navn" - "Sende melding" - "Markere inneværende måned"
        
             . "Varsling på fødselsdager". ("Notification on birthdays")           --> "NotificationTableView.swift"
               . Legg inn Info
               . Legg in sjekk om varslinger til brukeren
        
           . Se om visningen av "Persondata kan gjøre raskere med background thread.
              "Introduction to iOS Threading - Zelda App (Xcode 8, Swift 3)" på Youtube.com av Mark Moeykens
             . DispatchQueue.global(qos: .userInteractive).async {
                   self.tableData = Data.getData()
                   DispatchQueue.main.async {
                       self.tableView.reloadData()
                   }
               }
        
           . Se igjennom opsjonene for Kart i PersonViewController.
           . Se igjennom opsjonene for sending av meldinger.
           . Oppdatere security i Firebase (er security der det samme for Firestore?)
        
        8. Programmerings tips
        
           a) SearchBar Xcode
              . Show Search Results Button
                .. searchBarResultsListButtonClicked()
              . Show Booksmark Button
                .. searchBarBookmarkButtonClicked()
              . Show Cancel Button
                .. searchBarCancelButtonClicked()
              . UpdateUserViewConrtoller: myTimer = Timer.scheduledTimer(timeInterval: TimeInterval(forsinkelse), target: self, selector: #selector(showUserInformation), userInfo: nil, repeats: false)
             . UpdatePasswordViewController: self.myTimer = Timer.scheduledTimer(timeInterval: TimeInterval(self.forsinkelse),target: self,selector: #selector(self.returnToLogin), userInfo: nil, repeats: true)
           b) Info om strings in Swift: https://oleb.net/blog/2017/11/swift-4-strings/
        c) Info om timer: https://www.raywenderlich.com/113835-ios-timer-tutorial
        d) Info om header: https://www.hackingwithswift.com/example-code/uikit/how-to-add-a-section-header-to-a-table-view
        e) Generell info: https://www.hackingwithswift.com
        f) Mer: https://github.com/ioscreator/ioscreator
        g) Mer: https://github.com/ioscreator/ioscreator/blob/master/IOS12SendiMessageTutorial/IOS12SendiMessageTutorial/ViewController.swift
        h) Mer: https://github.com/ioscreator/ioscreator/tree/master/IOS12SendEmailTutorial
        
        9. Firestore
           a) Informasjon
              . https://firebase.google.com/docs/firestore/data-model
              . Har gode queriesProgrammerings oppgaver:
              . Søkefunksjon i Firestore i PersonViewController på både fornavn og/eller etternavn
        
        9. Feil som må rettes
        
           a) Det kan legges inn flere like poster når en legger inn en ny person
           b) Vise default bilde og ikke et som er valgt tidligere når det ikke er en tilsvarende photoURL i Firebase Storage (usikker om dette er tilfellet lenger?).
        
        10. Concurrency
        
            Why concurrency? As soon as you add heavy tasks to your app like data loading it slows your UI work down or even freezes it. Concurrency lets you perform 2 or more tasks “simultaneously”. The disadvantage of this approach is that thread safety which is not always as easy to control. F.e. when different tasks want to access the same resources like trying to change the same variable on a different threads or accessing the resources already blocked by the different threads.
        
            There are a few abstractions we need to be aware of.
        
            Queues.
            Synchronous/Asynchronous task performance.
            Priorities.
            Common troubles.
        
            Queues.
        
            Must be serial or concurrent. As well as global or private at the same time.
        
            With serial queues, tasks will be finished one by one while with concurrent queues, tasks will be performed simultaneously and will be finished on unexpected schedules. The same group of tasks will take the way more time on a serial queue compared to a concurrent queue.
        
            You can create your own private queues (both serial or concurrent) or use already available global (system) queues. The main queue is the only serial queue out of all of the global queues.
        
            It is highly recommended to not perform heavy tasks which are not referred to UI work on the main queue (f.e. loading data from the network), but instead to do them on the other queues to keep the UI unfrozen and responsive to the user actions. If we let the UI be changed on the other queues, the changes can be made on a different and unexpected schedule and speed. Some UI elements can be drawn before or after they are needed. It can crash the UI. We also need to keep in mind that since the global queues are system queues there are some other tasks can run by the system on them.
        
        
            Quality of service / priority.
        
            Queues also have different qos (Quality of Service) which sets the task performing priority (from highest to lowest here):
            .userInteractive - main queue
            .userInitiated - for the user initiated tasks on which user waits for some response
            .utility - for the tasks which takes some time and doesn't require immediate response, e.g working with data
            .background - for the tasks which aren't related with the visual part and which aren't strict for the completion time).
        
            There is also
        
            .default queue which does't transfer the qos information. If it wasn't possible to detect the qos the qos will be used between .userInitiated and .utility.
        
        
            Tasks can be performed synchronously or asynchronously.
        
            Synchronous function returns control to the current queue only after the task is finished. It blocks the queue and waits until the task is finished.
            Asynchronous function returns control to the current queue right after task has been sent to be performed on the different queue. It doesn't wait until the task is finished. It doesn't block the queue.
        
            Common troubles.
        
            The most popular mistakes programmers make while projecting the concurrent apps are the following:
        
            Race condition - caused when the app work depends on the order of the code parts execution.
            Priority inversion - when the higher priority tasks wait for the smaller priority tasks to be finished due to some resources being blocked
            Deadlock - when a few queues have infinite wait for the sources (variables, data etc.) already blocked by some of these queues.
            NEVER call the sync function on the main queue.
            If you call the sync function on the main queue it will block the queue as well as the queue will be waiting for the task to be completed but the task will never be finished since it will not be even able to start due to the queue is already blocked. It is called deadlock.
        
            When to use sync? When we need to wait until the task is finished. F.e. when we are making sure that some function/method is not double called. F.e. we have synchronization and trying to prevent it to be double called until it's completely finished. Here's some code for this concern:
            How to find out what caused error crash report on IOS device?
        
        
        """
        
    }
    
}
