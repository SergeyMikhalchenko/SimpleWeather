//
//  SearchTableViewController.swift
//  SimpleWeather
//
//  Created by Sergey Mikhalchenko on 05.04.16.
//  Copyright © 2016 Sergey Mikhalchenko. All rights reserved.
//

import Foundation
import UIKit

class SearchTableViewController: UITableViewController, UISearchResultsUpdating {

    var searchController = UISearchController()
    
    var searchResults = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerNib(UINib(nibName: "UniversalTextTableViewCell", bundle: nil),
                                   forCellReuseIdentifier: "UniversalTextTableViewCell")
        self.tableView.registerNib(UINib(nibName: "SearchLocationTableViewCell", bundle: nil),
                                   forCellReuseIdentifier: "SearchLocationTableViewCell")
        
        self.setupSearchController()
    }
    
    func setupSearchController() {
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        
        self.searchController.searchBar.sizeToFit()
        self.searchController.searchBar.searchBarStyle = .Minimal
        self.searchController.searchBar.barTintColor = UIColor.whiteColor()
        self.tableView.tableHeaderView = self.searchController.searchBar
        
        self.searchController.hidesNavigationBarDuringPresentation = true
    }
    
// MARK: - Setup UITableViewController
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            if searchController.active {
                return searchResults.count > 0 ? searchResults.count : 1
            } else {
                return 1
            }
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            if searchController.active {
                    
                    if searchResults.count > 0 {
                        let identifier = "SearchLocationTableViewCell"
                        var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? SearchLocationTableViewCell
                        if cell == nil {
                            tableView.registerNib(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
                            cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? SearchLocationTableViewCell
                        }
                        
                        let location = searchResults[indexPath.row] as! NSDictionary
                        
                        
                        if let country = (location["sys"] as! NSDictionary).objectForKey("country") {
                             cell?.locationName.text = "\((location["name"])!) \(country)"
                        } else {
                            cell?.locationName.text = "\((location["name"])!)"
                        }
                        let temp = ((location["main"] as! NSDictionary).objectForKey("temp"))!
                        cell?.temperature.text = String(format: "t = %3.1f C", temp as! Float)
                        cell?.weatherDescription.text = "\((location["weather"] as! NSArray).firstObject!.objectForKey("main")!)"
                        cell?.cityID = location["id"] as! Int
                        
                        return cell!
                    } else {
                        let identifier = "UniversalTextTableViewCell"
                        var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? UniversalTextTableViewCell
                        if cell == nil {
                            tableView.registerNib(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
                            cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? UniversalTextTableViewCell
                        }
                        
                        cell?.setLabelText("Sorry. Any result for your request. Try again.")
                        
                        return cell!
                    }
                
            } else {
                
                let identifier = "UniversalTextTableViewCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? UniversalTextTableViewCell
                if cell == nil {
                    tableView.registerNib(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
                    cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? UniversalTextTableViewCell
                }
                
                cell?.setLabelText("Start typing name of location in search field.")
                
                return cell!
            }

        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

// MARK: - UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        let queue = (searchController.searchBar.text!).lowercaseString
        
        if queue.characters.count > 2 {
            LocationWeather().searchByCityName(name: queue, completion: { (result) in
                
                self.searchResults = []
                self.searchResults = result
                
                
                }) { (error) in
                    print("\(error.description)")
            }
        } else {
            self.searchResults = []
        }
            
        self.tableView.reloadData()
    }
    
}