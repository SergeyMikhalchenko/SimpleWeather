//
//  CurrentLocationRealm.swift
//  SimpleWeather
//
//  Created by Sergey Mikhalchenko on 05.04.16.
//  Copyright © 2016 Sergey Mikhalchenko. All rights reserved.
//

import Foundation
import RealmSwift

class CurrentLocationRealm: Object {
    
    dynamic var latitude: Double = 0
    dynamic var longitude: Double = 0
    dynamic var updateTime: Double = 0
    
    dynamic var locationAvailable: Bool = false

}