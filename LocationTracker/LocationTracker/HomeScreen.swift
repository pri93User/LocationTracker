//
//  HomeScreen.swift
//  LocationTracker
//
//  Created by Apple on 15/01/22.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class HomeScreen: UIViewController,CLLocationManagerDelegate {
    
     @IBOutlet var btnStart : UIButton!
     @IBOutlet var mapView : MKMapView!
    
    
    
    var locationManager: CLLocationManager?
    var permissionGranted: Bool = false
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()

        
    }
    
    func setupView() {
        
        // Location manager setup
        locationManager = CLLocationManager()
       
        self.requestPermission()
        self.requestCapabilities()
        

        if CLLocationManager.locationServicesEnabled() {
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager?.startUpdatingLocation()
          }
       
    }
    
    //MARK: Location Permission and methods
    
   func requestPermission() {
        locationManager?.requestAlwaysAuthorization()
        

    }
    
   func requestCapabilities() {
        checkCapabilities()
    }
    
    func checkCapabilities() {
        
        var output = "";
        if (CLLocationManager.significantLocationChangeMonitoringAvailable()) {
            output = "- Significant Location Change Monitoring Available"
        }
        
        if (CLLocationManager.headingAvailable()) {
            output = "\(output)\n- Heading Available"
        }
        
        if (CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self)) {
            output = "\(output)\n- Monitoring Available"
        }
        
        if (CLLocationManager.isRangingAvailable()) {
            output = "\(output)\n- Ranging Available"
        }
        
        if (CLLocationManager.locationServicesEnabled()) {
            output = "\(output)\n- Location services enabled"
        }
        
      
    }
    
    @IBAction func start_click(_ sender: Any) {
        
        if (!permissionGranted) {
            
            let alert = UIAlertController(title: "Error", message: "Location permission not granted. Select 'Request Permission' first.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            
            let trackervc = self.storyboard?.instantiateViewController(withIdentifier: "TrackerScreen") as! TrackerScreen
            self.navigationController?.pushViewController(trackervc, animated: true)
        }
        
        
        
    }
    
    //MARK: location delegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            permissionGranted = true
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            
            print("New location is \(location)")
            showCurrentLocation(location: location)
            locationManager?.stopUpdatingLocation()
        }
    }
    

    
    //MARK: Show current location on map
    func showCurrentLocation(location:CLLocation)  {
        
       
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        let geoCoder = CLGeocoder ()
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            if let placemarks = placemarks, placemarks.count > 0 {
                let placemark = placemarks[0]
                let addressDictionary = placemark.name;
                print("source address: \(String(describing: addressDictionary))")
                print("placemark: \(String(describing: placemark))")
               // annotation.title = addressDictionary!["Name"] as? String
                    self.mapView.addAnnotation(annotation)
                }
            })
    }
    
    
    
    
}
