//
//  PathScreen.swift
//  LocationTracker
//
//  Created by Apple on 15/01/22.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class PathScreen: UIViewController,MKMapViewDelegate {
    
    @IBOutlet var mapView : MKMapView!
   @IBOutlet var infoView: UIView!
    
    @IBOutlet var lblDistance : UILabel!
    @IBOutlet var lblTime : UILabel!
    @IBOutlet var lblHoldTime : UILabel!
   
   var locationManager: CLLocationManager?
    var infoDict : Dictionary<String, Any>!
    var locationArray : NSMutableArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()

        print("info dictionary :: \(String(describing: infoDict))")
    }
    
    func setupView()  {
        
        mapView.isZoomEnabled = true
        
        lblTime.text = infoDict["time"] as? String
        lblHoldTime.text = infoDict["holdtime"] as? String
        lblDistance.text = infoDict["distance"] as? String

        locationArray = infoDict["locations"] as? NSMutableArray
        
        showPathOnMAp()
        
    }
    
    @IBAction func start_click(_ sender: Any) {
        

            let trackervc = self.storyboard?.instantiateViewController(withIdentifier: "TrackerScreen") as! TrackerScreen
            self.navigationController?.pushViewController(trackervc, animated: true)
        
    }
    func showPathOnMAp()  {
        
        let sourceLocation = locationArray.firstObject as! CLLocation
        let destinationLocation = locationArray.lastObject as! CLLocation
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation.coordinate, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation.coordinate, addressDictionary: nil)
                
               
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
                
        let geoCoder = CLGeocoder ()
        
        let sourceAnnotation = MKPointAnnotation()
        
                
        if let location = sourcePlacemark.location {
                sourceAnnotation.coordinate = location.coordinate
        }
        
        
        geoCoder.reverseGeocodeLocation(sourceLocation, completionHandler: { (placemarks, error) -> Void in
            if let placemarks = placemarks, placemarks.count > 0 {
                let placemark = placemarks[0]
                let addressDictionary = placemark.addressDictionary
                print("source address: \(String(describing: addressDictionary))")

                sourceAnnotation.title = addressDictionary!["Name"] as? String
 //               self.mapView.addAnnotation(sourceAnnotation)
                }
            })
                
        let destinationAnnotation = MKPointAnnotation()
       
                
        if let location = destinationPlacemark.location {
                destinationAnnotation.coordinate = location.coordinate
        }
        
        geoCoder.reverseGeocodeLocation(destinationLocation, completionHandler: { (placemarks, error) -> Void in
            if let placemarks = placemarks, placemarks.count > 0 {
                let placemark = placemarks[0]
                let addressDictionary = placemark.addressDictionary
                print("destination address: \(addressDictionary)")
                destinationAnnotation.title = addressDictionary!["Name"] as? String
//                self.mapView.addAnnotation(destinationAnnotation)
                }
            })
      
        self.mapView.addAnnotations([sourceAnnotation,destinationAnnotation])
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
                
                
        let directions = MKDirections(request: directionRequest)
                
               
        directions.calculate {
                
            (response, error) -> Void in
                    
                guard let response = response else {
                    if let error = error {
                        print("Error in route: \(error)")
                    }
                        
                    return
                }
                    
            let route = response.routes[0]
            self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
                    
            let rect = route.polyline.boundingMapRect
            
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
                }
    }
    
    //MARK: mapview delegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 5.0
        
            return renderer
        }
}
