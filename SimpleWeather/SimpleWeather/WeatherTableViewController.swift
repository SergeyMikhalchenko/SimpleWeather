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
import Whisper

class WeatherTableViewController: UITableViewController {
    
    var currentLocationWeather: Results<CurrentLocationWeatherRealm>!
    var locationWeatherListing: Results<LocationWeatherRealm>!

    var refresherControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doneButton = UIBarButtonItem(title: "Search", style: .Done, target: self, action: #selector(WeatherTableViewController.buttonSearchPressed))
        self.navigationItem.rightBarButtonItem = doneButton
        
        self.refresherControl = UIRefreshControl()
        self.refresherControl.addTarget(self, action: #selector(WeatherTableViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresherControl)
        
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

        self.locationWeatherListing = LocationWeather().getLocationsWeather(completion: { (result) in
            
            self.locationWeatherListing = result
            self.tableView.reloadData()
            
            }, failure: { (error) in
                print("\(error.description)")
        })
    }
    
//MARK: - Refresh
    
    func refresh(sender: AnyObject) {
        
        if Reachability.connectedToNetwork() {
            
            CurrentLocationWeather().getByCurrentLocation({ (result) in
                
                self.currentLocationWeather = result
                
                LocationWeather().getLocationsWeather(completion: { (result) in
                    
                    self.locationWeatherListing = result
                    self.tableView.reloadData()
                    self.refresherControl.endRefreshing()

                    }, failure: { (error) in
                        print("\(error.description)")
                        self.refresherControl.endRefreshing()
                })
                
                }, failure: { (error) in
                    print("\(error.description)")
                    self.refresherControl.endRefreshing()
            })
            
        } else {
            self.refresherControl.endRefreshing()
            
            let message = Murmur(
                title: "No internet connection.",
                duration: 1.5,
                backgroundColor: UIColor.lightGrayColor(),
                titleColor: UIColor.blackColor(),
                font:  UIFont.systemFontOfSize(12)
            )
            
            Whistle(message)
        }
    }
    
//MARK: - Custom methods and tools
    
    func buttonSearchPressed() {
        self.performSegueWithIdentifier("loadSearchTableViewController", sender: self)
    }

//MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "loadDetailViewController" {
            if let cell = sender as? LocationTableViewCell {
                
                let vc = segue.destinationViewController as! DetailWeatherViewController
                vc.locationID = cell.locationID
            }
        }
    }
    
//MARK: - TableViewCustomization
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
            case 0:
                if self.currentLocationWeather?.count > 0 {
                    return 1
                }
                return 0
            case 1:
                if let count = locationWeatherListing?.count {
                    return count
                }
                return 0
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
                cell?.temperature.text = String(format: "Temperature: %3.1f C", temp)
                cell?.weatherDescription.text = (currentLocationWeather.first?.main)!
                cell?.locationID = (currentLocationWeather.first?.id)!
            default:
                cell?.locationName.text = "\(locationWeatherListing[indexPath.row].name), \(locationWeatherListing[indexPath.row].country)"
                let temp = locationWeatherListing[indexPath.row].temp
                cell?.temperature.text = String(format: "Temperature: %3.1f C", temp)
                cell?.weatherDescription.text = locationWeatherListing[indexPath.row].main
                cell?.locationID = locationWeatherListing[indexPath.row].id
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
        
        let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! LocationTableViewCell
        
        self.performSegueWithIdentifier("loadDetailViewController", sender: cell)
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
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let width = UIScreen.mainScreen().bounds.width
        
        let label = UILabel(frame: CGRectZero)
        label.frame = CGRect(x: 0, y: 5, width: width, height: 15)
        label.textAlignment = .Center
        label.textColor = UIColor.grayColor()
        label.text = ""
        
        let view = UIView(frame:CGRect(x: 0, y: 0, width: width, height: 20))
        view.addSubview(label)
        view.backgroundColor = UIColor.clearColor()
        
        switch section {
        case 0:
            label.text = "Current location"
            return view
        case 1:
            label.text = "Favorite locations"
            return view
        default:
            return UIView(frame: CGRectZero)
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 25
        case 1:
            return 25
        default:
            return 0
        }
        
    }
}


