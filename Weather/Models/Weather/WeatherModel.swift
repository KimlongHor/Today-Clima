//
//  WeatherModel.swift
//  Weather
//
//  Created by horkimlong on 6/24/20.
//  Copyright © 2020 horkimlong. All rights reserved.
//

import Foundation
import RealmSwift

class WeatherModel: Object{
    
    @objc dynamic var cityName: String = ""
    @objc dynamic var information: WeatherInformation?
    
    required init() {}
    
    init(cityName: String, information: WeatherInformation) {
        self.cityName = cityName
        self.information = information
    }
    
}
