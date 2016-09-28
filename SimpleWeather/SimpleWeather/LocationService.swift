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
    
    var timer: Timer!
    
    var latitude: Double! = 0
    var longitude: Double! = 0
    
    var lastUpdateTime: TimeInterval! = 0
    
    static let sharedInstance = LocationService()
    override init() {
        super.init()
        
        self.locationManager = CLLocationManager()
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager?.distanceFilter = 500
        self.locationManager?.delegate = self
        self.locationManager?.pausesLocationUpdatesAutomatically = false
        
        self.locationManager?.requestAlwaysAuthorization()
        
        self.self.locationManager?.startUpdatingLocation()
        self.timer = Timer.scheduledTimer(
            timeInterval: 300.0,
            target: self,
            selector: #selector(LocationService.updateLocationWithTimer),
            userInfo: nil,
            repeats: true
        )
    }
    
    func startUpdatingLocation() {
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                print("No access to location services.")
            case .authorizedAlways, .authorizedWhenInUse:
                self.locationManager?.startUpdatingLocation()
            }
        } else {
            print("Location services are not enabled")
        }
    }
    
    func stopUpdatingLocation() {
        self.locationManager?.stopUpdatingLocation()
    }
    
    func updateLocationWithTimer() {
        self.startUpdatingLocation()
    }
}

extension LocationService: CLLocationManagerDelegate {

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location: CLLocation = locations.last!
        
        self.currentLocation = location

        self.stopUpdatingLocation()
        
        self.latitude = self.currentLocation!.coordinate.latitude
        self.longitude = self.currentLocation!.coordinate.longitude
        self.lastUpdateTime = Date().timeIntervalSince1970
        
        CurrentLocation().updateGPSLocation(latitude: latitude, longitude: longitude, updateTime: lastUpdateTime)
        print("time = \(Int(self.lastUpdateTime)) lat = \(self.latitude) lon = \(self.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedAlways {
            print("LocationManager: Authorization success")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
            print("Location manager: \(error.localizedDescription)")
    }
}
