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
    
    var baseURL: URL!
    
    let realm: Realm!
    
    static let sharedInstance = ServerManager()
    override init() {
        realm = try! Realm()
        super.init()
        
        let baseString = String(format: "%@%@/", apiURL, apiVersion)
        baseURL = URL(string: baseString)
    }
    
    
    func get(method: String,
                    parameters: [String:AnyObject]?,
                    completion: @escaping (AnyObject?) -> Void,
                    failure: @escaping (_ error: NSError?) -> Void) {
        
        var parameters = parameters //Swift 3 will deprecate var varible in function declaration
        parameters!["APPID"] = apiKey as AnyObject?
        parameters!["mode"] = "json" as AnyObject?
        
        let request = String(format: "%@%@", baseURL as CVarArg, method)
        
        Alamofire.request(request, method: .get, parameters: parameters).responseJSON { (response) in
            
            guard response.result.isSuccess else {
                print("GET: Request error = \(response.result.error)")
                failure(response.result.error as NSError?)
                return
            }
            
            if let JSON = response.result.value {
                print("GET: Request successful = \(response.response!.url!)")
                
                if let statusCode = response.response?.statusCode {
                    print("statusCode = \(statusCode)")
                    if 200...299 ~= statusCode {
                        completion(JSON as AnyObject?)
                    }
                }
            }
        }
    }
        
    
}
