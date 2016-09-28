//
//  SearchLocationTableViewCell.swift
//  SimpleWeather
//
//  Created by Sergey Mikhalchenko on 05.04.16.
//  Copyright © 2016 Sergey Mikhalchenko. All rights reserved.
//

import Foundation
import UIKit
//import Whisper

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
        
        self.addLocationButton.layer.cornerRadius = self.addLocationButton.bounds.height / 2.0
        self.addLocationButton.clipsToBounds = true
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        
        if Reachability().connectedToNetwork() {
            
            LocationWeather().getByCityID(self.cityID, completion: { (result) in
                print("getByCityID success")
            }) { (error) in
                print(error?.description)
            }
            
        } else {
            
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
}
