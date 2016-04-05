//
//  CurrentLocation.swift
//  SimpleWeather
//
//  Created by Sergey Mikhalchenko on 05.04.16.
//  Copyright © 2016 Sergey Mikhalchenko. All rights reserved.
//

import Foundation
import RealmSwift

class CurrentLocation: ServerManager {
    
    override init() {
        super.init()
    }
    
    func updateGPSLocation(latitude latitude: Double, longitude: Double, updateTime: Double) {
        
        self.realm.beginWrite()
        self.realm.delete(self.realm.objects(CurrentLocationRealm.self))
        
        let location = CurrentLocationRealm()
        
        location.latitude = latitude
        location.longitude = longitude
        location.updateTime = updateTime
        
        self.realm.add(location, update: false)
        
        try! self.realm.commitWrite()
    }
    
    func getGPSLocation() -> Results<CurrentLocationRealm>? {
        return self.realm.objects(CurrentLocationRealm.self)
    }
}