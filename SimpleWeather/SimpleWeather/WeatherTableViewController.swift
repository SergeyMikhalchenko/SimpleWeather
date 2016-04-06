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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doneButton = UIBarButtonItem(title: "Search", style: .Done, target: self, action: #selector(WeatherTableViewController.buttonSearchPressed))
        self.navigationItem.rightBarButtonItem = doneButton
        
        self.tableView.delegate = self
        self.tableView.registerNib(UINib(nibName: "LocationTableViewCell", bundle: nil), forCellReuseIdentifier: "LocationTableViewCell")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        self.currentLocationWeather = CurrentLocationWeather().getByCurrentLocation({ (result) in
            
            self.currentLocationWeather = result
            self.tableView.reloadData()
            
            }, failure: { (error) in
                print("\(error.description)")
        })
        
        self.locationWeatherListing = LocationWeather().getByCityID(0, completion: { (result) in
            
            self.locationWeatherListing = result
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
            case 1: return locationWeatherListing.count
            default: return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0, 1:
            let identifier = "LocationTableViewCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? LocationTableViewCell
            if cell == nil {
                tableView.registerNib(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
                cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? LocationTableViewCell
            }
            
            switch indexPath.section {
            case 0:
                cell?.locationName.text = "\((currentLocationWeather.first?.name)!), \((currentLocationWeather.first?.country)!)"
                let temp = (currentLocationWeather.first?.temp)!
                cell?.temperature.text = String(format: "t = %3.1f C", temp)
                cell?.weatherDescription.text = (currentLocationWeather.first?.main)!
            default:
                cell?.locationName.text = "\((locationWeatherListing.first?.name)!), \((locationWeatherListing.first?.country)!)"
                let temp = (locationWeatherListing.first?.temp)!
                cell?.temperature.text = String(format: "t = %3.1f C", temp)
                cell?.weatherDescription.text = (locationWeatherListing.first?.main)!
                cell?.locationID = (locationWeatherListing.first?.id)
            }
            
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
        self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        switch indexPath.section {
        case 1: return true
        default: return false
        }
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
       
        switch indexPath.section {
        case 1:
            let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! LocationTableViewCell
            
            let delete = UITableViewRowAction(style: .Default, title: "Delete") { action, index in
                LocationWeather().deleteLocation(locationID: cell.locationID, completion: { (result) in
                    self.locationWeatherListing = result
                    self.tableView.reloadData()
                })
            }
            delete.backgroundColor = UIColor.redColor()
            
            return [delete]
        default:
            return []
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}


