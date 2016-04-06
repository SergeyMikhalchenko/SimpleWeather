//
//  DetailWeatherViewController.swift
//  SimpleWeather
//
//  Created by Sergey Mikhalchenko on 05.04.16.
//  Copyright © 2016 Sergey Mikhalchenko. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class DetailWeatherViewController: UIViewController {
 
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var currentTemperature: UILabel!
    @IBOutlet weak var maxTemperature: UILabel!
    @IBOutlet weak var minTemperature: UILabel!
    @IBOutlet weak var weatherDescription: UILabel!
    @IBOutlet weak var humidityLevel: UILabel!
    @IBOutlet weak var pressureLevel: UILabel!
    @IBOutlet weak var windSpeed: UILabel!
    @IBOutlet weak var cloudnessLevel: UILabel!
    @IBOutlet weak var sunriseTime: UILabel!
    @IBOutlet weak var sunsetTime: UILabel!
    
    var locationID: Int! = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
    }
    
    func setupView() {
        
        // Need to remove dublication
        
        let currentlocation = CurrentLocationWeather().getLocationFromCache(id: locationID)
        if currentlocation.isEmpty {
            let location = LocationWeather().getLocationFromCache(id: locationID)
            
            self.locationName.text = location.first?.name
            self.currentTemperature.text = String(format: "Current t: %3.1f C", (location.first?.temp)!)
            self.maxTemperature.text = String(format: "Max t: %3.1f C", (location.first?.temp_max)!)
            self.minTemperature.text = String(format: "Min t: = %3.1f C", (location.first?.temp_min)!)
            self.weatherDescription.text = location.first?.main
            self.humidityLevel.text = String(format: "Humidity: %d%%", (location.first?.humidity)!)
            self.pressureLevel.text = String(format: "Pressure: %6.1f hPa", (location.first?.pressure)!)
            self.windSpeed.text = String(format: "Wind speed: %3.1f m/s", (location.first?.wind_speed)!)
            self.cloudnessLevel.text = String(format: "Cloudness: %d%%", (location.first?.clouds_all)!)
            self.sunriseTime.text = self.dateFormating((location.first?.sunrise)!)
            self.sunsetTime.text = self.dateFormating((location.first?.sunset)!)
            
        } else {
            
            self.locationName.text = currentlocation.first?.name
            self.currentTemperature.text = String(format: "Current t: %3.1f C", (currentlocation.first?.temp)!)
            self.maxTemperature.text = String(format: "Max t: %3.1f C", (currentlocation.first?.temp_max)!)
            self.minTemperature.text = String(format: "Min t: = %3.1f C", (currentlocation.first?.temp_min)!)
            self.weatherDescription.text = currentlocation.first?.main
            self.humidityLevel.text = String(format: "Humidity: %d%%", (currentlocation.first?.humidity)!)
            self.pressureLevel.text = String(format: "Pressure: %6.3f hPa", (currentlocation.first?.pressure)!)
            self.windSpeed.text = String(format: "Wind speed: %3.1f m/s", (currentlocation.first?.wind_speed)!)
            self.cloudnessLevel.text = String(format: "Cloudness: %d%%", (currentlocation.first?.clouds_all)!)
            self.sunriseTime.text = self.dateFormating((currentlocation.first?.sunrise)!)
            self.sunsetTime.text = self.dateFormating((currentlocation.first?.sunset)!)
        }
    }
    
    func dateFormating(time: Double) -> String {
        
        let date = NSDate(timeIntervalSince1970: time)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        return dateFormatter.stringFromDate(date)
    }
}