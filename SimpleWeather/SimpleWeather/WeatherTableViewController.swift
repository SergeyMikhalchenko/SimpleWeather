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
//import Whisper

class WeatherTableViewController: UITableViewController {
    
    var currentLocationWeather: Results<CurrentLocationWeatherRealm>!
    var locationWeatherListing: Results<LocationWeatherRealm>!

    var locationServiceAvailable: Bool = false
    
    var refresherControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doneButton = UIBarButtonItem(title: "Search", style: .done, target: self, action: #selector(WeatherTableViewController.buttonSearchPressed))
        self.navigationItem.rightBarButtonItem = doneButton
        
        self.refresherControl = UIRefreshControl()
        self.refresherControl.addTarget(self, action: #selector(WeatherTableViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refresherControl)
        
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: "LocationTableViewCell", bundle: nil), forCellReuseIdentifier: "LocationTableViewCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.locationServiceAvailable = CurrentLocation().isServiceAvailable()
        
        self.currentLocationWeather = CurrentLocationWeather().getByCurrentLocation({ (result) in
            
            self.currentLocationWeather = result
            self.tableView.reloadData()
            
            }, failure: { (error) in
                print("\(error?.description)")
        })

        self.locationWeatherListing = LocationWeather().getLocationsWeather(completion: { (result) in
            
            self.locationWeatherListing = result
            self.tableView.reloadData()
            
            }, failure: { (error) in
                print("\(error?.description)")
        })
    }
    
//MARK: - Refresh
    
    func refresh(_ sender: AnyObject) {
        
        self.locationServiceAvailable = CurrentLocation().isServiceAvailable()


        if Reachability().connectedToNetwork() {
            
            CurrentLocationWeather().getByCurrentLocation({ (result) in
                
                self.currentLocationWeather = result
                
                LocationWeather().getLocationsWeather(completion: { (result) in
                    
                    self.locationWeatherListing = result
                    self.tableView.reloadData()
                    self.refresherControl.endRefreshing()

                    }, failure: { (error) in
                        print("\(error?.description)")
                        self.refresherControl.endRefreshing()
                })
                
                }, failure: { (error) in
                    print("\(error?.description)")
                    self.refresherControl.endRefreshing()
            })
            
        } else {
            self.refresherControl.endRefreshing()
            
//            let message = Murmur(
//                title: "No internet connection.",
//                duration: 1.5,
//                backgroundColor: UIColor.lightGray,
//                titleColor: UIColor.black,
//                font:  UIFont.systemFont(ofSize: 12)
//            )
//            
//            Whistle(message)
        }
    }
    
//MARK: - Custom methods and tools
    
    func buttonSearchPressed() {
        self.performSegue(withIdentifier: "loadSearchTableViewController", sender: self)
    }

//MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "loadDetailViewController" {
            if let cell = sender as? LocationTableViewCell {
                
                let vc = segue.destination as! DetailWeatherViewController
                vc.locationID = cell.locationID
            }
        }
    }
    
//MARK: - TableViewCustomization
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
            case 0:
                return 1
            case 1:
                if (locationWeatherListing?.count)! > 0 {
                    return (locationWeatherListing?.count)!
                }
                return 1
            default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch (indexPath as NSIndexPath).section {
        case 0, 1:
            let identifier = "LocationTableViewCell"
            var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? LocationTableViewCell
            if cell == nil {
                tableView.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
                cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? LocationTableViewCell
            }
            
            switch (indexPath as NSIndexPath).section {
            case 0:
                if (locationServiceAvailable && !currentLocationWeather.isEmpty) {
                    cell?.locationName.text = "\((currentLocationWeather.first?.name)!), \((currentLocationWeather.first?.country)!)"
                    let temp = (currentLocationWeather.first?.temp)!
                    cell?.temperature.text = String(format: "Temperature: %3.1f C", temp)
                    cell?.weatherDescription.text = (currentLocationWeather.first?.main)!
                    cell?.locationID = (currentLocationWeather.first?.id)!
                    cell?.isUserInteractionEnabled = true
                } else {
                    cell?.locationName.text = "Location unavailable."
                    cell?.temperature.text = String(format: "Temperature: Unknown")
                    cell?.weatherDescription.text = "Please, pull to refresh."
                    cell?.locationID = 0
                    cell?.isUserInteractionEnabled = false
                }
            default:
                
                if (locationWeatherListing?.count)! > 0 {
                    cell?.locationName.text = "\(locationWeatherListing[indexPath.row].name), \(locationWeatherListing[indexPath.row].country)"
                    let temp = locationWeatherListing[indexPath.row].temp
                    cell?.temperature.text = String(format: "Temperature: %3.1f C", temp)
                    cell?.weatherDescription.text = locationWeatherListing[indexPath.row].main
                    cell?.locationID = locationWeatherListing[indexPath.row].id
                } else {
                    let identifier = "UniversalTextTableViewCell"
                    var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? UniversalTextTableViewCell
                    if cell == nil {
                        tableView.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
                        cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? UniversalTextTableViewCell
                    }
                    
                    cell?.mainLabel.text = "Press \"Search\" to find and add locations."
                    
                    cell?.isUserInteractionEnabled = false
                    
                    return cell!
                }
            }
            
            return cell!
        default:
            return UITableViewCell()
        }
    }
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableView.deselectRow(at: indexPath, animated: false)
        
        let cell = self.tableView.cellForRow(at: indexPath) as! LocationTableViewCell
        
        self.performSegue(withIdentifier: "loadDetailViewController", sender: cell)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        switch (indexPath as NSIndexPath).section {
        case 1: return true
        default: return false
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
       
        switch (indexPath as NSIndexPath).section {
        case 1:
            let cell = self.tableView.cellForRow(at: indexPath) as! LocationTableViewCell
            
            let delete = UITableViewRowAction(style: .default, title: "Delete") { action, index in
                LocationWeather().deleteLocation(locationID: cell.locationID, completion: { (result) in
                    self.locationWeatherListing = result
                    self.tableView.reloadData()
                })
            }
            delete.backgroundColor = UIColor.red
            
            return [delete]
        default:
            return []
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let width = UIScreen.main.bounds.width
        
        let label = UILabel(frame: CGRect.zero)
        label.frame = CGRect(x: 0, y: 5, width: width, height: 15)
        label.textAlignment = .center
        label.textColor = UIColor.gray
        label.text = ""
        
        let view = UIView(frame:CGRect(x: 0, y: 0, width: width, height: 20))
        view.addSubview(label)
        view.backgroundColor = UIColor.clear
        
        switch section {
        case 0:
            label.text = "Current location"
            return view
        case 1:
            label.text = "Favorite locations"
            return view
        default:
            return UIView(frame: CGRect.zero)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
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


