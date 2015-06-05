//
//  ViewController.swift
//  LocationStarter1
//
//  Created by S Venu Madhav Chitta on 6/4/15.
//  Copyright (c) 2015 S Venu Madhav Chitta. All rights reserved.
//
import Foundation
import UIKit
import CoreLocation

let LATITUDE = "latitude"
let LONGITUDE = "longitude"
let ACCURACY = "theAccuracy"

class LocationTracker : NSObject, CLLocationManagerDelegate, UIAlertViewDelegate {
    
    var myLastLocation : CLLocationCoordinate2D?
    var myLastLocationAccuracy : CLLocationAccuracy?
    var shareModel : LocationShareModel?
    var myLocation : CLLocationCoordinate2D?
    var myLocationAcuracy : CLLocationAccuracy?
    var myLocationAltitude : CLLocationDistance?
    
    override init()  {
        super.init()
        self.shareModel = LocationShareModel()
        self.shareModel!.myLocationArray = NSMutableArray()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationEnterBackground", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
    }
    
    class func sharedLocationManager()->CLLocationManager? {
        
        struct Static {
            static var _locationManager : CLLocationManager?
        }
        
        objc_sync_enter(self)
        if Static._locationManager == nil {
            Static._locationManager = CLLocationManager()
            Static._locationManager!.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        }
        
        objc_sync_exit(self)
        return Static._locationManager!
    }
    
    // MARK: Application in background
    func applicationEnterBackground() {
        var locationManager : CLLocationManager = LocationTracker.sharedLocationManager()!
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        
        self.shareModel!.bgTask = BackgroundTaskManager.sharedBackgroundTaskManager()
        self.shareModel?.bgTask?.beginNewBackgroundTask()
    }
    
    func restartLocationUpdates() {
        print("restartLocationUpdates\n")
        
        if self.shareModel?.timer != nil {
            self.shareModel?.timer?.invalidate()
            self.shareModel!.timer = nil
        }
        
        var locationManager : CLLocationManager = LocationTracker.sharedLocationManager()!
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
    }
    
    func startLocationTracking() {
        print("startLocationTracking\n")
        
        if CLLocationManager.locationServicesEnabled() == false {
            print("locationServicesEnabled false\n")
            var servicesDisabledAlert : UIAlertView = UIAlertView(title: "Location Services Disabled", message: "You currently have all location services for this device disabled", delegate: nil, cancelButtonTitle: "OK")
            servicesDisabledAlert.show()
        } else {
            
            
            var authorizationStatus : CLAuthorizationStatus = CLLocationManager.authorizationStatus()
            if (authorizationStatus == CLAuthorizationStatus.Denied) || (authorizationStatus == CLAuthorizationStatus.Restricted) {
                NSLog("authorizationStatus failed")
            } else {
                var locationManager : CLLocationManager = LocationTracker.sharedLocationManager()!
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
                locationManager.distanceFilter = kCLDistanceFilterNone
                locationManager.requestAlwaysAuthorization()
                locationManager.startUpdatingLocation()
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        trace("locationManager didUpdateLocations\n")
        for (var i : Int = 0; i < locations.count; i++) {
            var newLocation : CLLocation = locations[i] as! CLLocation
            var theLocation : CLLocationCoordinate2D = newLocation.coordinate
            var theAltitude : CLLocationDistance = newLocation.altitude
            var theAccuracy : CLLocationAccuracy = newLocation.horizontalAccuracy
            var locationAge : NSTimeInterval = newLocation.timestamp.timeIntervalSinceNow
            if locationAge > 30.0 {
                continue
            }
            
            
            //NSLog("Location is \(newLocation)")
            
            // Select only valid location and also location with good accuracy
            self.myLastLocation = theLocation
            self.myLastLocationAccuracy = theAccuracy
            
            var dict : NSMutableDictionary = NSMutableDictionary()
            
            // Add the vallid location with good accuracy into an array
            // Every 1 minute, I will select the best location based on accuracy and send to server
            self.shareModel!.myLocationArray!.addObject(dict)
        }
        // If the timer still valid, return it (Will not run the code below)
        if self.shareModel!.timer != nil {
            return
        }
        
        self.shareModel!.bgTask = BackgroundTaskManager.sharedBackgroundTaskManager()
        self.shareModel!.bgTask!.beginNewBackgroundTask()
        
        // Restart the locationMaanger after 1 minute
        let restartLocationUpdates : Selector = "restartLocationUpdates"
        self.shareModel!.timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: restartLocationUpdates, userInfo: nil, repeats: false)
        
        // Will only stop the locationManager after 10 seconds, so that we can get some accurate locations
        // The location manager will only operate for 10 seconds to save battery
        let stopLocationDelayBy10Seconds : Selector = "stopLocationDelayBy10Seconds"
        var delay10Seconds : NSTimer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: stopLocationDelayBy10Seconds, userInfo: nil, repeats: false)
    }
    
    //MARK: Stop the locationManager
    func stopLocationDelayBy10Seconds() {
        var locationManager : CLLocationManager = LocationTracker.sharedLocationManager()!
        locationManager.stopUpdatingLocation()
        trace("locationManager stop Updating after 10 seconds\n")
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        
        switch (error.code) {
            
            
        case CLError.Network.rawValue:
            var alert : UIAlertView = UIAlertView(title: "Network Error", message: "Please check your network connection.", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            break
        case CLError.Denied.rawValue:
            var alert : UIAlertView = UIAlertView(title: "Network Error", message: "Please check your network connection.", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            break
        default:
            break
        }
        
    }
    
    func stopLocationTracking () {
        print("stopLocationTracking\n")
        
        if self.shareModel!.timer != nil {
            self.shareModel!.timer!.invalidate()
            self.shareModel!.timer = nil
        }
        var locationManager : CLLocationManager = LocationTracker.sharedLocationManager()!
        locationManager.stopUpdatingLocation()
    }
    
}

