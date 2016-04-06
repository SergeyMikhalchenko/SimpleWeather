//
//  ServerManager.swift
//  SimpleWeather
//
//  Created by Sergey Mikhalchenko on 05.04.16.
//  Copyright © 2016 Sergey Mikhalchenko. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift

class ServerManager: NSObject {
    
    
    let apiURL = "http://api.openweathermap.org/data/"
    let apiVersion = "2.5"
    let apiKey = "22741422a121cbd32c2694e9ecd1deac"
    
    var baseURL: NSURL!
    
    let realm: Realm!
    
    static let sharedInstance = ServerManager()
    override init() {
        realm = try! Realm()
        super.init()
        
        let baseString = String(format: "%@%@/", apiURL, apiVersion)
        baseURL = NSURL(string: baseString)
    }
    
    
    func get(method method: String,
                    parameters: [String:AnyObject]?,
                    completion: (AnyObject?) -> Void,
                    failure: (error: NSError!) -> Void) {
        
        var parameters = parameters //Swift 3 will deprecate var varible in function declaration
        parameters!["APPID"] = apiKey
        parameters!["mode"] = "json"
        
        let request = String(format: "%@%@", baseURL, method)
                
        Alamofire.request(.GET, request, parameters: parameters).responseJSON { (response) in
            
            guard response.result.isSuccess else {
                print("GET: Request error = \(response.result.error)")
                failure(error: response.result.error)
                return
            }
            
            if let JSON = response.result.value {
                print("GET: Request successful = \(response.response!.URL!)")
                completion(JSON)
            }
        }
    }
        
    
}