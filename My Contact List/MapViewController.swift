//
//  MapViewController.swift
//  My Contact List
//
//  Created by Noel Maldonado on 4/1/20.
//  Copyright © 2020 Noel Maldonado. All rights reserved.
//

import UIKit

import MapKit

import CoreData

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var sgmtMapType: UISegmentedControl!
    
    
    var locationManager: CLLocationManager!
    var contacts:[Contact] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mapView.delegate = self
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        //get contacts from Core Data
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "Contact")
        var fetchedObjects:[NSManagedObject] = []
        do {
            fetchedObjects = try context.fetch(request)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        contacts = fetchedObjects as! [Contact]
       //remove all annotations
            self.mapView.removeAnnotations(self.mapView.annotations)
            //go through all contacts
            for contact in contacts { //as! [Contact] {
                let address = "\(contact.streetAddress!), \(contact.city!) \(contact.state!)"
                //geocoding
                let geoCoder = CLGeocoder()
                geoCoder.geocodeAddressString(address) {(placemarks, error) in
                    self.processAddressResponse(contact, withPlacemarks: placemarks, error: error)
                }
            }
        }
    

    private func processAddressResponse(_ contact: Contact, withPlacemarks placemarks: [CLPlacemark]?,
                                        error: Error?) {
        if let error = error {
            print("Geocode Error: \(error)")
        }
        else {
            var bestMatch: CLLocation?
            if let placemarks = placemarks, placemarks.count > 0 {
                bestMatch = placemarks.first?.location
            }
            if let coordinate = bestMatch?.coordinate {
                let mp = MapPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
                mp.title = contact.contactName
                mp.subtitle = "\(contact.streetAddress ?? ""), \(contact.city ?? "")"
                mapView.addAnnotation(mp)
            }
            else {
                print("Didn't find any matching locations")
            }
        }
    }
    
    
    
    
    
    @IBAction func findUser(_ sender: Any) {
//        mapView.showsUserLocation = true
//        mapView.setUserTrackingMode(.follow, animated: true)
        isLocationAccessEnabled()
//        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        //Span used to indicate how many degrees are visible on the map; used to specify the zoom level
        var span = MKCoordinateSpan()
        span.latitudeDelta = 0.2
        span.longitudeDelta = 0.2
        let viewRegion = MKCoordinateRegion(center: userLocation.coordinate, span: span)
        mapView.setRegion(viewRegion, animated: true)
        
        let mp = MapPoint(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        mp.title = "You"
        mp.subtitle = "Are Here"
        mapView.addAnnotation(mp)
    }
    
    
    
    
    @IBAction func mapTypeChanged(_ sender: Any) {
        switch sgmtMapType.selectedSegmentIndex {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .hybrid
        case 2:
            mapView.mapType = .satellite
        default: break
        }
    }
    
    //checks to see if its Enabled
    func isLocationAccessEnabled () {
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .restricted, .denied:
                print("not Enabled")
                //grabs path to apps location service settings location
                let settingsAppURL = URL(string: UIApplication.openSettingsURLString)!
                
//                if let url = URL(string: UIApplication.openSettingsURLString) {
//                    if UIApplication.shared.canOpenURL(url) {
//                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                    }
//                }
                
                
                //sets up alert
                let alert = UIAlertController(title: "Location Services disabled", message: "Location access is required to use \"Find me!\"", preferredStyle: .alert)
                //sets cancel action
                let okAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                //sets up action to trasfer the User to allow location access
                let allowAccess = UIAlertAction(title: "Allow Location Acess", style: .cancel, handler: {
//                    (alert) -> Void in UIApplication.shared.openURL(NSURL(string: "prefs:root=LOCATION_SERVICES")! as URL)
                    
                    (alert) -> Void in UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
                })
                //adds actions
                alert.addAction(okAction)
                alert.addAction(allowAccess)
                //presents the alert
                present(alert, animated: true, completion: nil)
                
            case .authorizedAlways, .authorizedWhenInUse:
                print("Enabled")
                mapView.showsUserLocation = true
                
                mapView.setUserTrackingMode(.follow, animated: true)
            case .notDetermined:
                print("Not determined")
                locationManager.requestWhenInUseAuthorization()
            }
        } else {
            print("failed to check location services")
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
