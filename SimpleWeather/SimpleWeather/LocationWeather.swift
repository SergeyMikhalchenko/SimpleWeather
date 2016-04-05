//
//  LocationWeather.swift
//  SimpleWeather
//
//  Created by Sergey Mikhalchenko on 05.04.16.
//  Copyright © 2016 Sergey Mikhalchenko. All rights reserved.
//

import Foundation
import RealmSwift

class LocationWeather: ServerManager {

    override init() {
        super.init()
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
            //self.realm.delete(self.realm.objects(LocationWeatherRealm.self))
                let locationWeather = LocationWeatherRealm()
                
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
            
            completion(result: self.realm.objects(LocationWeatherRealm.self))
            }, failure: { (error) in
                failure(error: error)
        })

        return self.realm.objects(LocationWeatherRealm.self)
    }
    
    func searchByCityName(name
        queueName: String!,
        completion:(result: NSArray) -> Void,
        failure:(error:NSError!) -> Void) -> NSArray { //Any cache
        
        let method = "find"
        let parameters: [String:AnyObject] = [
            "q":queueName,
            "cnt":0,
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
}














