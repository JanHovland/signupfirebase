//
//  MapViewController.swift
//  signupfirebase
//
//  Created by Jan Hovland on 05/03/2019.
//  Copyright © 2019 Jan . All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet var mapView: MKMapView!
    
    var titleMap: String = ""
    var subtitle: String = ""
    var locationOnMap: String = ""
    var address: String = ""
    var changeName: String = ""
    var changeLatitude: Double = 60.429350
    var changeLlongitude: Double = 9.465658
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = titleMap
        
        mapView.delegate = self
        
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.showsTraffic = true
        mapView.showsBuildings = true
        // mapView.showsPointsOfInterest = true

        
        // Convert address to coordinate and annotate it on map
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(locationOnMap, completionHandler: { placemarks, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let placemarks = placemarks {
                // Get the first placemark
                let placemark = placemarks[0]
                
                // Add annotation
                let annotation = MKPointAnnotation()
                
                if let location = placemark.location {
                    
                    annotation.coordinate = location.coordinate

                    if self.changeName.count > 0 {
                        annotation.coordinate.latitude = self.changeLatitude
                        annotation.coordinate.longitude = self.changeLlongitude
                    }
                    
                    annotation.title = self.address
                    annotation.subtitle = self.subtitle
                    
                    // Display the annotationn
                    self.mapView.showAnnotations([annotation], animated: true)
                    self.mapView.selectAnnotation(annotation, animated: true)
                    
                }
            }
            
        })
        
    }
    
 }
