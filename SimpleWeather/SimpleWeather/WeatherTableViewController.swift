//
//  ViewController.swift
//  SimpleWeather
//
//  Created by Sergey Mikhalchenko on 05.04.16.
//  Copyright © 2016 Sergey Mikhalchenko. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class WeatherTableViewController: UITableViewController {
    
    var currentLocationWeather: Results<CurrentLocationWeatherRealm>!
    var locationWeatherListing: Results<LocationWeatherRealm>!
    
    let cellIdentifier = "LocationTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doneButton = UIBarButtonItem(title: "Search", style: .Done, target: self, action: Selector("buttonSearchPressed"))
        self.navigationItem.rightBarButtonItem = doneButton
        
        self.tableView.delegate = self
        self.tableView.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        self.currentLocationWeather = CurrentLocationWeather().getByCurrentLocation({ (result) in
            
            self.currentLocationWeather = result
            self.tableView.reloadData()
            
            }, failure: { (error) in
                print("\(error.description)")
        })
    }

//MARK: - Custom methods and tools
    
    func buttonSearchPressed() {
        self.performSegueWithIdentifier("loadSearchTableViewController", sender: self)
    }

//MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
//MARK: - TableViewCustomization
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
            case 0: return 1
            case 1: return 0//locationWeatherListing.count
            default: return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? LocationTableViewCell
            if cell == nil {
                tableView.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
                cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? LocationTableViewCell
            }
            
            cell?.locationName.text = "\((currentLocationWeather.first?.name)!), \((currentLocationWeather.first?.country)!)"
            let temp = (currentLocationWeather.first?.temp)!
            cell?.temperature.text = String(format: "t = %3.1f C", temp)
            cell?.weatherDescription.text = (currentLocationWeather.first?.main)!
            cell?.currentLocationLabel.text = "Current location"
        
            return cell!
        default:
            return UITableViewCell()
        }
    }
    

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}


