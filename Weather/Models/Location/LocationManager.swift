//
//  LocationManager.swift
//  Weather
//
//  Created by horkimlong on 6/26/20.
//  Copyright © 2020 horkimlong. All rights reserved.
//

import Foundation

protocol LocationManagerDelegate {
    func didUpdateLocation(_ locationManager: LocationManager, location: [LocationModel])
    
    func didFailWithError(error: Error)
}

struct LocationManager {
    var locationURL = "https://api.teleport.org/api/cities/?search="
    
    var delegate : LocationManagerDelegate?
    
    func fetchLocation (str: String){
        let convertedStr = str.replacingOccurrences(of: " ", with: "%20")
        let urlString: String = "\(locationURL)\(convertedStr)"
        //print(urlString)
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String){
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    self.delegate?.didFailWithError(error: error)
                    return
                }
                
                if let safeData = data {
                    if let location = self.parseJSON(safeData){
//                        print(location)
                        self.delegate?.didUpdateLocation(self, location: location)
                    }
                }
            }
            
            task.resume()
        }
    }
    
    func parseJSON(_ locationData: Data) -> [LocationModel]?{
        let decoder = JSONDecoder()
        do {
            let decodeData = try decoder.decode(LocationData.self, from: locationData)
            
            var locations = [LocationModel]()
            var location = LocationModel()
            
            let cities = decodeData.embedded.citySearchResults
            
            for city in cities{
                location.fullName = city.matchingFullName
                location.link = city.links.cityItem.href
                
                locations.append(location)
            }
            
            return locations
        } catch {
            self.delegate?.didFailWithError(error: error)
            return nil
        }
        
    }
}
