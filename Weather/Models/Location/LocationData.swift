//
//  LocationData.swift
//  Weather
//
//  Created by horkimlong on 6/26/20.
//  Copyright © 2020 horkimlong. All rights reserved.
//

import Foundation

// MARK: - Welcome
struct LocationData: Codable {
    let embedded: Embedded

    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
    }
}

// MARK: - Embedded
struct Embedded: Codable {
    let citySearchResults: [CitySearchResult]

    enum CodingKeys: String, CodingKey {
        case citySearchResults = "city:search-results"
    }
}

// MARK: - CitySearchResult
struct CitySearchResult: Codable {
    let links: CitySearchResultLinks
    let matchingFullName: String

    enum CodingKeys: String, CodingKey {
        case links = "_links"
        case matchingFullName = "matching_full_name"
    }
}

// MARK: - CitySearchResultLinks
struct CitySearchResultLinks: Codable {
    let cityItem: SelfClass

    enum CodingKeys: String, CodingKey {
        case cityItem = "city:item"
    }
}

// MARK: - SelfClass
struct SelfClass: Codable {
    let href: String
}
