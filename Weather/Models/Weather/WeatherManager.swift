//
//  WeatherManager.swift
//  Weather
//
//  Created by horkimlong on 6/24/20.
//  Copyright © 2020 horkimlong. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    
    func didFailWithError(error : Error)
}

class WeatherManager {
//    var longitude: Double = 0
//    var latitude: Double = 0
    var weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=\(apiKey)&units=imperial"
    
    var delegate : WeatherManagerDelegate?
    
    var cityManager = CityManager()
    
    func fetchWeather (latitude: Double, longitude: Double){
        let urlString: String = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString, latitude: latitude, longitude: longitude)
    }
    
    func fetchWeather (lat: CLLocationDegrees, lon: CLLocationDegrees){
        let latitude = Double(lat)
        let longitude = Double(lon)
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString, latitude: latitude, longitude: longitude)
    }
    
    func performRequest(with urlString: String, latitude: Double, longitude: Double){
        // create URL
        if let url = URL(string: urlString){
            // create URL session
            let session = URLSession(configuration: .default)
            // Give the session a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    self.delegate?.didFailWithError(error: error)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(safeData){
                        weather.information?.longitude = longitude
                        weather.information?.latitude = latitude
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
        
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do {
            let decodeData = try decoder.decode(WeatherData.self, from: weatherData)
            // Decoding Jason into swift
            let name = decodeData.name
            
            let temp = decodeData.main.temp
            let humid = decodeData.main.humidity
            let pressure = decodeData.main.pressure
            
            let speed = decodeData.wind.speed
            let sunRise = decodeData.sys.sunrise
            let sunSet = decodeData.sys.sunset
            
            let weatherID = decodeData.weather[0].id
            
            let timeZone = decodeData.timezone
            
            let currentTime = decodeData.dt
            
            let weatherInfo = WeatherInformation(temperature: temp, humidity: humid, pressure: pressure, windSpeed: speed, currentTime: currentTime, sunRise: sunRise, sunSet: sunSet, timeZone: timeZone, conditionId: weatherID, longitude: 0, latitude: 0)
        
            let weather = WeatherModel(cityName: name, information: weatherInfo)
            
            return weather
        } catch {
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
