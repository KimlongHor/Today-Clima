//
//  WeatherData.swift
//  Weather
//
//  Created by horkimlong on 6/24/20.
//  Copyright © 2020 horkimlong. All rights reserved.
//

import Foundation

struct WeatherData: Decodable{
    let name: String
    let main: Main
    let wind: Wind
    let sys: Sys
    let weather: [Weather]
    let timezone: Int
    let dt: Int
}

struct Main: Decodable{
    let temp: Double
    let humidity: Double
    let pressure: Double
}

struct Wind: Decodable{
    let speed: Double
}

struct Sys: Decodable {
    let sunrise: Int
    let sunset: Int
}

struct Weather: Decodable {
    let id: Int
}
