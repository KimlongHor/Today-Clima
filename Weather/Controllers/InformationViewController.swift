//
//  InformationViewController.swift
//  Weather
//
//  Created by horkimlong on 6/23/20.
//  Copyright © 2020 horkimlong. All rights reserved.
//

import UIKit

class InformationViewController: UIViewController {
    
    @IBOutlet weak var backgroundColorImage: UIImageView!
    @IBOutlet weak var sunOrMoonImage: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var sunSetLabel: UILabel!
    @IBOutlet weak var sunRiseLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    
    var selectedLocation: WeatherModel?
    var checkDayOrNight: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        sunSetLabel.text = getSunsetTimeString()
        sunRiseLabel.text = getSunriseTimeString()
        
        if let safeName = selectedLocation?.cityName{
            cityNameLabel.text = String(safeName)
            cityNameLabel.font = UIFont(name: "Roboto-Regular", size: 54)
        }
        
        if let safeTemp = selectedLocation?.information?.temperature{
            let intTemp = Int(safeTemp)
            if UserDefaults.standard.bool(forKey: "TempUnit"){
                temperatureLabel.text = String(intTemp) + "ºF"
            } else {
                temperatureLabel.text = String(((intTemp - 32) * 5) / 9) + "ºC"
            }
            
        }
        if let safeWindSpeed = selectedLocation?.information?.windSpeed {
            windSpeedLabel.text = String(safeWindSpeed) + " m/s"
        }
        if let safeHumid = selectedLocation?.information?.humidity{
            humidityLabel.text = String(safeHumid) + " %"
        }
        
        // if daytime = true, else (nightTime) = false
        
        if checkDayOrNight == true {
            backgroundColorImage.image = UIImage(named: "YellowBackground")
            sunOrMoonImage.image = UIImage(named: "Sun")
        } else {
            backgroundColorImage.image = UIImage(named: "BlueBackground")
            sunOrMoonImage.image = UIImage(named: "Moon")
        }
        
    }
    
    @IBAction func returnButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getSunsetTimeString() -> String{
        let sunSet = Double(selectedLocation?.information?.sunSet ?? 0)
        let timeZone = Double(selectedLocation?.information?.timeZone ?? 0)
        let unixTimeStamp = sunSet + timeZone
        let timeString = unixToUTC(with: unixTimeStamp)
        return timeString + " pm"
    }
    
    func getSunriseTimeString() -> String{
        let sunRise = Double(selectedLocation?.information?.sunRise ?? 0)
        let timeZone = Double(selectedLocation?.information?.timeZone ?? 0)
        let unixTimeStamp = sunRise + timeZone
        let timeString = unixToUTC(with: unixTimeStamp)
        return timeString + " am"
    }
    
    func unixToUTC(with unixTimeStamp: Double)-> String{
        let date = Date(timeIntervalSince1970: unixTimeStamp)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "HH:mm"
        // yyyy-MM-dd
        let strDate = dateFormatter.string(from: date)
        return strDate
    }
}
