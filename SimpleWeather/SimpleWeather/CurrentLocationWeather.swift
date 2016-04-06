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
        completion:(result: Results<CurrentLocationWeatherRealm>?) -> Void,
        failure:(error:NSError!) -> Void) -> Results<CurrentLocationWeatherRealm>? {
        
        if let location: Results<CurrentLocationRealm>! = CurrentLocation().getGPSLocation() {
            if let lon = location?.first?.longitude {
                self.lon = lon
            }
            if let lat = location?.first?.latitude {
                self.lat = lat
            }
        }
        
        let method = "weather"
        let parameters: [String:AnyObject] = [
            "lon":self.lon,
            "lat":self.lat,
            "cnt":1,
            "units":"metric"
        ]
        
        ServerManager.sharedInstance.get(method: method, parameters: parameters, completion: { (response) in
            
            let result = response as! Dictionary<String, AnyObject>
            
            self.realm.beginWrite()
            self.realm.delete(self.realm.objects(CurrentLocationWeatherRealm.self))
            
                let locationWeather = CurrentLocationWeatherRealm()
                
                locationWeather.id = result["id"] as! Int
                locationWeather.name = result["name"] as! String
                locationWeather.country = (result["sys"] as! NSDictionary).objectForKey("country") as! String
                locationWeather.cod = result["cod"] as! Int
                locationWeather.lon = result["coord"]!["lon"] as! Float
                locationWeather.lat = result["coord"]!["lat"] as! Float
                locationWeather.dt = result["dt"] as! Double
                locationWeather.sunrise = (result["sys"] as! NSDictionary).objectForKey("sunrise") as! Double
                locationWeather.sunset = (result["sys"] as! NSDictionary).objectForKey("sunset") as! Double
                
                locationWeather.main = ((result["weather"] as! NSArray).firstObject as! NSDictionary).objectForKey("main") as! String
                locationWeather.mainDescription = ((result["weather"] as! NSArray).firstObject as! NSDictionary).objectForKey("description") as! String
                locationWeather.temp = (result["main"] as! NSDictionary).objectForKey("temp") as! Float
                locationWeather.pressure = (result["main"] as! NSDictionary).objectForKey("pressure") as! Float
                locationWeather.humidity = (result["main"] as! NSDictionary).objectForKey("humidity") as! Int
                
                locationWeather.temp_min = (result["main"] as! NSDictionary).objectForKey("temp_min") as! Float
                locationWeather.temp_max = (result["main"] as! NSDictionary).objectForKey("temp_max") as! Float
                
                locationWeather.wind_speed = (result["wind"] as! NSDictionary).objectForKey("speed") as! Float
                locationWeather.clouds_all = (result["clouds"] as! NSDictionary).objectForKey("all") as! Int
            
            self.realm.add(locationWeather, update: true)
            
            try! self.realm.commitWrite()
            
            completion(result: self.realm.objects(CurrentLocationWeatherRealm.self))
            }, failure: { (error) in
                failure(error: error)
        })
        
        return self.realm.objects(CurrentLocationWeatherRealm.self)
    }
}