//
//  SearchTableViewController.swift
//  SimpleWeather
//
//  Created by Sergey Mikhalchenko on 05.04.16.
//  Copyright © 2016 Sergey Mikhalchenko. All rights reserved.
//

import Foundation
import UIKit
//import Whisper

class SearchTableViewController: UITableViewController, UISearchResultsUpdating {

    var searchController = UISearchController()
    
    var searchResults = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: "UniversalTextTableViewCell", bundle: nil),
                                   forCellReuseIdentifier: "UniversalTextTableViewCell")
        self.tableView.register(UINib(nibName: "SearchLocationTableViewCell", bundle: nil),
                                   forCellReuseIdentifier: "SearchLocationTableViewCell")
        
        self.setupSearchController()
    }
    
    func setupSearchController() {
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        
        self.searchController.searchBar.sizeToFit()
        self.searchController.searchBar.searchBarStyle = .minimal
        self.searchController.searchBar.barTintColor = UIColor.white
        self.tableView.tableHeaderView = self.searchController.searchBar
        
        self.searchController.hidesNavigationBarDuringPresentation = true
    }
    
// MARK: - Setup UITableViewController
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            if searchController.isActive {
                return searchResults.count > 0 ? searchResults.count : 1
            } else {
                return 1
            }
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch (indexPath as NSIndexPath).section {
        case 0:
            if searchController.isActive {
                    
                    if searchResults.count > 0 {
                        let identifier = "SearchLocationTableViewCell"
                        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? SearchLocationTableViewCell
                        if cell == nil {
                            tableView.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
                            cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? SearchLocationTableViewCell
                        }
                        
                        let location = searchResults[(indexPath as NSIndexPath).row] as! NSDictionary
                        
                        
                        if let country = (location["sys"] as! NSDictionary).object(forKey: "country") {
                             cell?.locationName.text = "\((location["name"])!) \(country)"
                        } else {
                            cell?.locationName.text = "\((location["name"])!)"
                        }
                        let temp = ((location["main"] as! NSDictionary).object(forKey: "temp"))!
                        cell?.temperature.text = String(format: "Temperature: %3.1f C", temp as! Float)
                        cell?.weatherDescription.text = "\(((location["weather"] as! NSArray).firstObject! as AnyObject).object(forKey: "main")!)"
                        cell?.cityID = location["id"] as! Int
                        cell?.selectionStyle = .none
                        
                        return cell!
                    } else {
                        let identifier = "UniversalTextTableViewCell"
                        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? UniversalTextTableViewCell
                        if cell == nil {
                            tableView.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
                            cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? UniversalTextTableViewCell
                        }
                        
                        cell?.setLabelText("Sorry. Any result for your request. Try again.")
                        cell?.selectionStyle = .none
                        
                        return cell!
                    }
                
            } else {
                
                let identifier = "UniversalTextTableViewCell"
                var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? UniversalTextTableViewCell
                if cell == nil {
                    tableView.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
                    cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? UniversalTextTableViewCell
                }
                
                cell?.setLabelText("Start typing name of location in search field.")
                cell?.selectionStyle = .none
                
                return cell!
            }

        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }

// MARK: - UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        
        let queue = (searchController.searchBar.text!).lowercased()
        
        if queue.characters.count > 2 {
            
            if Reachability().connectedToNetwork() {
                self.searchResults = []
                LocationWeather().searchByCityName(name: queue, completion: { (result) in
                    
                    self.searchResults = []
                    self.searchResults = result
                    self.tableView.reloadData()
                    
                }) { (error) in
                    print("\(error?.description)")
                    self.tableView.reloadData()
                }
                
            } else {
                
//                let message = Murmur(
//                    title: "No internet connection.",
//                    duration: 1.5,
//                    backgroundColor: UIColor.lightGray,
//                    titleColor: UIColor.black,
//                    font:  UIFont.systemFont(ofSize: 12)
//                )
//                
//                Whistle(message)
            }

        } else {
            self.searchResults = []
            self.tableView.reloadData()
        }
    }
    
}
