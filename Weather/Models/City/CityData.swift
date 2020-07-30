//
//  CityData.swift
//  Weather
//
//  Created by horkimlong on 6/28/20.
//  Copyright © 2020 horkimlong. All rights reserved.
//

import Foundation

// MARK: - Welcome
struct CityData: Codable {
    let location: Location
}

// MARK: - Location
struct Location: Codable {
    let latlon: Latlon
}

// MARK: - Latlon
struct Latlon: Codable {
    let latitude, longitude: Double
}
