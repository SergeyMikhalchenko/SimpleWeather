//
//  ViewController.swift
//  SimpleWeather
//
//  Created by Sergey Mikhalchenko on 05.04.16.
//  Copyright © 2016 Sergey Mikhalchenko. All rights reserved.
//

import UIKit

class WeatherTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadWeather()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadWeather() {
        
        let metod = "weather"
        let parameters = [
            "q":"London"
        ]
        
        ServerManager.sharedInstance.get(
            method: metod,
            parameters: parameters
        ) { (response) in
                print("response = \(response)")
        }
    }
}

