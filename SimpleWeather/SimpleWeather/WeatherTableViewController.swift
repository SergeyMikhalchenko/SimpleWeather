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
        
//        LocationWeather().getByCityID(524901, completion: { (result) in
//            
//            print("Success = \(result)")
//            }) { (error) in
//                print("failure = \(error)")
//        }
        
        CurrentLocationWeather().getByCurrentLocation({ (result) in
            print("\(result)")
            }) { (error) in
                print("\(error)")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

