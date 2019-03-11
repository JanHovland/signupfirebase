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
    var locationOnMap: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = titleMap
        
        mapView.delegate = self
        
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.showsTraffic = true
        
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
                    
                    // Display the annotationn
                    self.mapView.showAnnotations([annotation], animated: true)
                    self.mapView.selectAnnotation(annotation, animated: true)
                    
                }
            }
            
        })
        
    }
   
}
