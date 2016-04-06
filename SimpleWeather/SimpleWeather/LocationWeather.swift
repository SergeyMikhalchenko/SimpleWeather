//
//  LocationWeather.swift
//  SimpleWeather
//
//  Created by Sergey Mikhalchenko on 05.04.16.
//  Copyright © 2016 Sergey Mikhalchenko. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire

class LocationWeather: ServerManager {

    override init() {
        super.init()
    }
    
    func getLocationsWeather(completion
        completion:(result: Results<LocationWeatherRealm>) -> Void,
        failure:(error:NSError!) -> Void) -> Results<LocationWeatherRealm> {
        
        var locationsID = [String]()
        let locations = self.realm.objects(LocationWeatherRealm.self)
        
        for location in locations {
            locationsID += ["\(location.id)"]
        }
        let ids = locationsID.joinWithSeparator(",")
        
        let method = "group"
        
        let parameters: [String:AnyObject] = [
            "id":ids,
            "units":"metric"
        ]
        
        ServerManager.sharedInstance.get(method: method, parameters: parameters, completion: { (response) in
            
            let result = response as! Dictionary<String, AnyObject>
            let locations: Array = result["list"] as! Array<Dictionary<String, AnyObject>>
            
            for location in locations {
                
                self.realm.beginWrite()
                let locationWeather = LocationWeatherRealm()
                
                locationWeather.id = location["id"] as! Int
                locationWeather.name = location["name"] as! String
                locationWeather.country = location["sys"]!["country"] as! String
                locationWeather.lon = location["coord"]!["lon"] as! Float
                locationWeather.lat = location["coord"]!["lat"] as! Float
                locationWeather.dt = location["dt"] as! Double
                locationWeather.sunrise = location["sys"]!["sunrise"] as! Double
                locationWeather.sunset = location["sys"]!["sunset"] as! Double
                
                locationWeather.main = ((location["weather"] as! NSArray).firstObject as! NSDictionary).objectForKey("main") as! String
                locationWeather.mainDescription = ((location["weather"] as! NSArray).firstObject as! NSDictionary).objectForKey("description") as! String
                locationWeather.temp = (location["main"] as! NSDictionary).objectForKey("temp") as! Float
                locationWeather.pressure = (location["main"] as! NSDictionary).objectForKey("pressure") as! Float
                locationWeather.humidity = (location["main"] as! NSDictionary).objectForKey("humidity") as! Int
                
                locationWeather.temp_min = (location["main"] as! NSDictionary).objectForKey("temp_min") as! Float
                locationWeather.temp_max = (location["main"] as! NSDictionary).objectForKey("temp_max") as! Float
                
                locationWeather.wind_speed = (location["wind"] as! NSDictionary).objectForKey("speed") as! Float
                locationWeather.clouds_all = (location["clouds"] as! NSDictionary).objectForKey("all") as! Int
                
                self.realm.add(locationWeather, update: true)
                try! self.realm.commitWrite()
            }
            
            completion(result: self.realm.objects(LocationWeatherRealm.self))
            }, failure: { (error) in
                failure(error: error)
        })
        
        return self.realm.objects(LocationWeatherRealm.self)
    }
    
    func getByCityID(
        id:Int,
        completion:(result: Results<LocationWeatherRealm>?) -> Void,
        failure:(error:NSError!) -> Void) -> Results<LocationWeatherRealm>? {
        
        let method = "weather"
        let parameters: [String:AnyObject] = [
            "id":id,
            "units":"metric"
        ]
        
        ServerManager.sharedInstance.get(method: method, parameters: parameters, completion: { (response) in
            
            let result = response as! Dictionary<String, AnyObject>
            
            self.realm.beginWrite()
            self.realm.delete(self.realm.objects(LocationWeatherRealm.self).filter("id == \(id)"))
                let locationWeather = LocationWeatherRealm()
                
                locationWeather.id = result["id"] as! Int
                locationWeather.name = result["name"] as! String
                locationWeather.country = (result["sys"] as! NSDictionary).objectForKey("country") as! String
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
            
            completion(result: self.realm.objects(LocationWeatherRealm.self))
            }, failure: { (error) in
                failure(error: error)
        })

        return self.realm.objects(LocationWeatherRealm.self)
    }
    
    func searchByCityName(name
        queueName: String,
        completion:(result: NSArray) -> Void,
        failure:(error:NSError!) -> Void) -> NSArray { //Any cache
        
        let method = "find"
        let parameters: [String:AnyObject] = [
            "q":queueName,
            "cnt":10,
            "type":"like",
            "units":"metric"
        ]
        
        ServerManager.sharedInstance.get(method: method, parameters: parameters, completion: { (response) in
            completion(result: response!["list"] as! NSArray)
        }) { (error) in
            failure(error: error)
        }
        
        return NSArray()
    }
    
    func deleteLocation(locationID
        id: Int,
        completion:(result: Results<LocationWeatherRealm>) -> Void) {

        self.realm.beginWrite()
        self.realm.delete(self.realm.objects(LocationWeatherRealm.self).filter("id == \(id)"))
        try! self.realm.commitWrite()

        completion(result: self.realm.objects(LocationWeatherRealm.self))
    }
    
    func getLocationFromCache(id id: Int) -> Results<LocationWeatherRealm> {
        return self.realm.objects(LocationWeatherRealm.self).filter("id == \(id)")
    }
}














