//
//  CityManager.swift
//  Weather
//
//  Created by horkimlong on 6/28/20.
//  Copyright © 2020 horkimlong. All rights reserved.
//

import Foundation

protocol CityManagerDelegate {
    func didUpdateCity(_ cityManager: CityManager, city: CityModel)
    
    func didFailWithErrorForCity(error: Error)
}

struct CityManager {
    
    var delegate : CityManagerDelegate?
    
    func fetchCityInfo(link: String){
        performRequest(with: link)
    }
    
    func performRequest(with link: String){
        if let url = URL(string: link){
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    self.delegate?.didFailWithErrorForCity(error: error)
                    return
                }
                
                if let safeData = data{
                    if let cityInfo = self.parseJSON(safeData){
                        self.delegate?.didUpdateCity(self, city: cityInfo)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ cityInfo: Data) -> CityModel?{
        let decoder = JSONDecoder()
        do {
            let decodeData = try decoder.decode(CityData.self, from: cityInfo)
            var city = CityModel()
            
            city.latitude = decodeData.location.latlon.latitude
            
            city.longitude = decodeData.location.latlon.longitude
            
            return city
            
            
        } catch {
            print("ParseJason Function in cityManager ->\(error)")
            return nil
        }
    }
}
