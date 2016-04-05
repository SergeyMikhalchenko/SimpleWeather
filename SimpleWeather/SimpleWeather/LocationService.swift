//
//  LocationManager.swift
//  SimpleWeather
//
//  Created by Sergey Mikhalchenko on 05.04.16.
//  Copyright © 2016 Sergey Mikhalchenko. All rights reserved.
//

import Foundation
import CoreLocation

class LocationService: NSObject {
    
    var locationManager: CLLocationManager?
    var currentLocation: CLLocation?
    
    var timer: NSTimer!
    
    var latitude: Double! = 0
    var longitude: Double! = 0
    
    var lastUpdateTime: NSTimeInterval! = 0
    
    static let sharedInstance = LocationService()
    override init() {
        super.init()
        
        self.locationManager = CLLocationManager()
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager?.distanceFilter = 500
        self.locationManager?.delegate = self
        self.locationManager?.pausesLocationUpdatesAutomatically = false
        
        self.locationManager?.requestAlwaysAuthorization()
        
        self.startUpdatingLocation()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(
            600.0,
            target: self,
            selector: #selector(LocationService.updateLocationWithTimer),
            userInfo: nil,
            repeats: true
        )
    }
    
    func startUpdatingLocation() {
        self.locationManager?.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        self.locationManager?.stopUpdatingLocation()
    }
    
    func updateLocationWithTimer() {
        self.locationManager?.startUpdatingLocation()
    }
}

extension LocationService: CLLocationManagerDelegate {

    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location: CLLocation = locations.last!
        
        self.currentLocation = location

        self.locationManager?.stopUpdatingLocation()
        
        self.latitude = self.currentLocation!.coordinate.latitude
        self.longitude = self.currentLocation!.coordinate.longitude
        self.lastUpdateTime = NSDate().timeIntervalSince1970
        
        CurrentLocation().updateGPSLocation(latitude: latitude, longitude: longitude, updateTime: lastUpdateTime)
        print("time = \(Int(self.lastUpdateTime)) lat = \(self.latitude) lon = \(self.longitude)")
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == .AuthorizedAlways {
            print("LocationManager: Authorization success")
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
            print("Location manager: \(error.description)")
    }
}
