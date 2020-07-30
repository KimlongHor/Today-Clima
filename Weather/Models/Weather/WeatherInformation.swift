//
//  WeatherInformation.swift
//  Weather
//
//  Created by horkimlong on 6/25/20.
//  Copyright © 2020 horkimlong. All rights reserved.
//

import Foundation
import RealmSwift

class WeatherInformation: Object{
    
    @objc dynamic var temperature: Double = 0
    @objc dynamic var humidity: Double = 0
    @objc dynamic var pressure: Double = 0
    @objc dynamic var windSpeed: Double = 0
    @objc dynamic var currentUTCTime: Int = 0
    @objc dynamic var sunRise: Int = 0
    @objc dynamic var sunSet: Int = 0
    @objc dynamic var timeZone: Int = 0
    @objc dynamic var conditionId: Int = 0
    @objc dynamic var longitude: Double = 0
    @objc dynamic var latitude: Double = 0
    @objc dynamic var fahrenheit: Bool = true
    
    var parentLocation = LinkingObjects(fromType: WeatherModel.self, property: "information")
    
    required init() {}
    
    init(temperature: Double, humidity: Double, pressure: Double, windSpeed: Double, currentTime: Int, sunRise: Int, sunSet: Int, timeZone: Int, conditionId: Int, longitude: Double, latitude: Double) {
        self.temperature = temperature
        self.humidity = humidity
        self.pressure = pressure
        self.windSpeed = windSpeed
        self.currentUTCTime = currentTime
        self.sunRise = sunRise
        self.sunSet = sunSet
        self.conditionId = conditionId
        self.longitude = longitude
        self.latitude = latitude
        self.timeZone = timeZone
    }
}
