//
//  TrackerScreen.swift
//  LocationTracker
//
//  Created by Apple on 15/01/22.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class TrackerScreen: UIViewController,CLLocationManagerDelegate {
    
    @IBOutlet var mapView : MKMapView!
    
    @IBOutlet var btnHold : UIButton!
    @IBOutlet var btnStop : UIButton!
    
    @IBOutlet var lblDistance : UILabel!
    @IBOutlet var lblTime : UILabel!
    @IBOutlet var lblHoldTime : UILabel!
    
    var isHold : Bool = false
    
    var timer : Timer!
    var holdtimer : Timer!
    var locationManager: CLLocationManager?
    
    var currSec,currMin : Int!
    var currSecHold,currMinHold : Int!
    
    var locationArray : NSMutableArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
 
        
    }
    
    func setupView()  {
        
        // Location manager setup
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.allowsBackgroundLocationUpdates = true
        
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(self.updateTime),
                                     userInfo: nil,
                                     repeats: true)
        
        currSec = 00
        currMin = 00
        
        currSecHold = 00
        currMinHold = 00
        
        lblDistance.text = "0 km"
        lblTime.text = String(format: "%d:%d", currMin,currSec)
        lblHoldTime.text = String(format: "%d:%d", currMinHold,currSecHold)
        
        locationManager?.startUpdatingLocation()
        locationArray = NSMutableArray()
    }
    
    
    
    
    //MARK: timers
    @IBAction func hold_click(_ sender: Any) {
        
        if isHold {
            //resume
            
            btnHold.setTitle("HOLD", for: UIControl.State.normal)
            btnHold.backgroundColor = UIColor.yellow
            
            holdtimer?.invalidate()
            holdtimer = nil
            
            timer = Timer.scheduledTimer(timeInterval: 1,
                                         target: self,
                                         selector: #selector(self.updateTime),
                                         userInfo: nil,
                                         repeats: true)
            locationManager?.startUpdatingLocation()
            isHold = false
            
        }
        else
        {
            //hold
            btnHold.setTitle("RESUME", for: UIControl.State.normal)
            btnHold.backgroundColor = UIColor.green

            timer?.invalidate()
            timer = nil
            
            holdtimer = Timer.scheduledTimer(timeInterval: 1,
                                         target: self,
                                         selector: #selector(self.updateHoldTime),
                                         userInfo: nil,
                                         repeats: true)
            locationManager?.stopUpdatingLocation()
            isHold = true
        }
       
    }
    
    @IBAction func stop_click(_ sender: Any) {
        
        if (timer != nil) {
            
        timer.invalidate()
        timer = nil
            
        }
        
        if (holdtimer != nil) {
            holdtimer.invalidate()
            holdtimer = nil
        }
       
        
        locationManager?.stopUpdatingLocation()
        
        self.showPath()
        
    }
    @objc func updateTime()
    {
        currSec += 1
        if currSec == 60 {
            currSec = 0
            currMin += 1
        }
        
        let timerStr = String(format: "%02d%@%02d", currMin,":",currSec)
        lblTime.text = timerStr
        
    }
    
    @objc func updateHoldTime()
    {
        currSecHold += 1
        if currSecHold == 60 {
            currSecHold = 0
            currMinHold += 1
        }
        
        let timerStr = String(format: "%02d%@%02d", currMinHold,":",currSecHold)
        lblHoldTime.text = timerStr
        
    }
    
    //MARK: Location manager delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            
            //print("New location is \(location)")
            
            if locationArray.count>0 {
               
                let previousLocation = locationArray.lastObject as! CLLocation
                let distanceInMeter = previousLocation.distance(from: location)
               
                print("disatance :: \(String(describing: distanceInMeter))")
                
                showDistance(distanceMeter: distanceInMeter)
            }
            
            
            
            locationArray.add(location)
            print("locationArray :: \(String(describing: locationArray))")
        }
    }
    
    func showDistance(distanceMeter: Double) {
        
        lblDistance.text = String(format: "%0.2f km", distanceMeter/1000)
    }
    
    func showPath()  {
        
        let data = ["distance":lblDistance.text!,
                    "time":lblTime.text!,
                    "holdtime":lblHoldTime.text!,
                    "locations":locationArray!] as [String : Any]
        let pathvc = self.storyboard?.instantiateViewController(withIdentifier: "PathScreen") as! PathScreen
        pathvc.infoDict = data
        self.navigationController?.pushViewController(pathvc, animated: true)
    }
}
