//
//  SearchLocationTableViewCell.swift
//  SimpleWeather
//
//  Created by Sergey Mikhalchenko on 05.04.16.
//  Copyright © 2016 Sergey Mikhalchenko. All rights reserved.
//

import Foundation
import UIKit

class SearchLocationTableViewCell: UITableViewCell {

    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var weatherDescription: UILabel!
    @IBOutlet weak var addLocationButton: UIButton!
    
    var cityID: Int! = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}