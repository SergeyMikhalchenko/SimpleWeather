//
//  CurrentLocationWeather.swift
//  SimpleWeather
//
//  Created by Sergey Mikhalchenko on 05.04.16.
//  Copyright © 2016 Sergey Mikhalchenko. All rights reserved.
//

import Foundation
import RealmSwift

class CurrentLocationWeather: ServerManager {
    
    var lon: Double = 0
    var lat: Double = 0
    
    override init() {
        super.init()
    }
    
    func getByCurrentLocation(
        _ completion:@escaping (_ result: Results<CurrentLocationWeatherRealm>?) -> Void,
        failure:@escaping (_ error:NSError?) -> Void) -> Results<CurrentLocationWeatherRealm>? {
        
        if let location: Results<CurrentLocationRealm>? = CurrentLocation().getGPSLocation() {
            if let lon = location?.first?.longitude {
                self.lon = lon
            }
            if let lat = location?.first?.latitude {
                self.lat = lat
            }
        }
        
        let method = "weather"
        let parameters: [String:AnyObject] = [
            "lon":self.lon as AnyObject,
            "lat":self.lat as AnyObject,
            "cnt":1 as AnyObject,
            "units":"metric" as AnyObject
        ]
        
        ServerManager.sharedInstance.get(method: method, parameters: parameters, completion: { (response) in
            
            let result = response as! Dictionary<String, AnyObject>
            
            self.realm.beginWrite()
            self.realm.delete(self.realm.objects(CurrentLocationWeatherRealm.self))
            
                let locationWeather = CurrentLocationWeatherRealm()
                
                locationWeather.id = result["id"] as! Int
                locationWeather.name = result["name"] as! String
                locationWeather.country = (result["sys"] as! NSDictionary).object(forKey: "country") as! String
                locationWeather.lon = result["coord"]!["lon"] as! Float
                locationWeather.lat = result["coord"]!["lat"] as! Float
                locationWeather.dt = result["dt"] as! Double
                locationWeather.sunrise = (result["sys"] as! NSDictionary).object(forKey: "sunrise") as! Double
                locationWeather.sunset = (result["sys"] as! NSDictionary).object(forKey: "sunset") as! Double
                
                locationWeather.main = ((result["weather"] as! NSArray).firstObject as! NSDictionary).object(forKey: "main") as! String
                locationWeather.mainDescription = ((result["weather"] as! NSArray).firstObject as! NSDictionary).object(forKey: "description") as! String
                locationWeather.temp = (result["main"] as! NSDictionary).object(forKey: "temp") as! Float
                locationWeather.pressure = (result["main"] as! NSDictionary).object(forKey: "pressure") as! Float
                locationWeather.humidity = (result["main"] as! NSDictionary).object(forKey: "humidity") as! Int
                
                locationWeather.temp_min = (result["main"] as! NSDictionary).object(forKey: "temp_min") as! Float
                locationWeather.temp_max = (result["main"] as! NSDictionary).object(forKey: "temp_max") as! Float
                
                locationWeather.wind_speed = (result["wind"] as! NSDictionary).object(forKey: "speed") as! Float
                locationWeather.clouds_all = (result["clouds"] as! NSDictionary).object(forKey: "all") as! Int
            
            self.realm.add(locationWeather, update: true)
            
            try! self.realm.commitWrite()
            
            completion(self.realm.objects(CurrentLocationWeatherRealm.self))
            }, failure: { (error) in
                failure(error)
        })
        
        return self.realm.objects(CurrentLocationWeatherRealm.self)
    }
    
    func getLocationFromCache(id: Int) -> Results<CurrentLocationWeatherRealm> {
        return self.realm.objects(CurrentLocationWeatherRealm.self).filter("id == \(id)")
    }
}
