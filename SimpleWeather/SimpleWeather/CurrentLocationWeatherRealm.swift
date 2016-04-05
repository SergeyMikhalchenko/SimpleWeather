//
//  CurrentLocationWeatherRealm.swift
//  SimpleWeather
//
//  Created by Sergey Mikhalchenko on 05.04.16.
//  Copyright © 2016 Sergey Mikhalchenko. All rights reserved.
//

import Foundation
import RealmSwift

class CurrentLocationWeatherRealm: Object {
    
    dynamic var id: Int = -1
    dynamic var name: String = ""
    dynamic var country: String = ""
    dynamic var cod: Int = -1
    
    dynamic var lon: Float = 0
    dynamic var lat: Float = 0
    
    dynamic var dt: Double = 0 //Time of data calculation
    
    dynamic var sunrise: Double = 0
    dynamic var sunset: Double = 0
    
    //Weather
    
    dynamic var main: String = ""
    dynamic var mainDescription: String = ""
    dynamic var temp: Float = 0
    dynamic var pressure: Float = 0
    dynamic var humidity: Int = 0   //%
    
    dynamic var temp_min: Float = 0
    dynamic var temp_max: Float = 0
    
    //Wind
    dynamic var wind_speed: Float = 0
    
    //Clouds
    dynamic var clouds_all: Int = 0    //%
    
    override static func primaryKey() -> String? {
        return "id"
    }
}