//
//  ViewController.swift
//  Weather
//
//  Created by horkimlong on 6/23/20.
//  Copyright © 2020 horkimlong. All rights reserved.
//

import UIKit
import RealmSwift
import CoreLocation
import Reachability
import gooey_cell
import Lottie

class LocationViewController: UIViewController {
    
    let realm = try! Realm()
    
    var cityCategory: Results<WeatherModel>?
    
    var locationManager = CLLocationManager()
    
    var isUserDefaultSet = false
    
    var animationView : AnimationView?
    
    let reachability = try! Reachability()
    
    var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
    var VW_overlay: UIView = UIView()

    
    @IBOutlet weak var tempUnitButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var weatherManager = WeatherManager()
    
    override func viewWillAppear(_ animated: Bool) {
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        animationView = .init(name: "tornado")
        animationView?.frame = view.bounds
        animationView?.loopMode = .loop
        animationView?.play()
        animationView?.backgroundColor = .white
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        label.center = CGPoint(x: 160, y: 285)
        label.textAlignment = .center
        label.text = "Fetching current location..."
        label.font = UIFont(name: "Roboto-Light", size: 15)
        
        animationView!.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: animationView!.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: animationView!.safeAreaLayoutGuide.bottomAnchor,constant: 16),
            label.widthAnchor.constraint(equalTo: animationView!.widthAnchor, multiplier: 1),
            label.heightAnchor.constraint(equalTo: animationView!.heightAnchor, multiplier: 0.3)
        ])
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        locationManager.delegate = self

        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()

        weatherManager.delegate = self
        let tempUnit = UserDefaults.standard.bool(forKey: "TempUnit")
        if tempUnit == true {
            tempUnitButton.setTitle("ºC", for: .normal)
        } else if tempUnit == false{
            tempUnitButton.setTitle("ºF", for: .normal)
        } else {
            tempUnitButton.setTitle("--", for: .normal)
        }
        
        VW_overlay = UIView(frame: UIScreen.main.bounds)
        VW_overlay.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)

        activityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        activityIndicatorView.frame = CGRect(x: 0, y: 0, width: activityIndicatorView.bounds.size.width, height: activityIndicatorView.bounds.size.height)

        activityIndicatorView.center = VW_overlay.center
        VW_overlay.addSubview(activityIndicatorView)
        VW_overlay.center = view.center
        
        tableView.delegate = self
        tableView.dataSource = self
        
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
            
            if CLLocationManager.authorizationStatus() != .denied{
                self.locationManager.requestLocation()
                self.view.addSubview(self.animationView!)
//                self.view.addSubview(self.VW_overlay)
//                self.activityIndicatorView.startAnimating()
            }
            //self.perform(#selector(self.loadCity), with: self.activityIndicatorView, afterDelay: 0.01)
            self.loadCity()
            self.checkTempUnit()
            
        }
        
        reachability.whenUnreachable = { _ in
            print("Not reachable")
            self.tableView.reloadData()
            let alert = UIAlertController(title: "Opps!", message: "No connection found...", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Get it", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        //loadCity()
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addCityController = storyboard.instantiateViewController(identifier: "CityVC") as! CityAddViewController
        addCityController.delegate = self
        self.present(addCityController, animated: true, completion: nil)
        
    }
    
    @IBAction func tempUnitButtonPressed(_ sender: UIButton) {
        
        let theButton = sender
        let bounds = theButton.bounds
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10, options: .curveEaseInOut, animations: {
            theButton.bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width + 60, height: bounds.size.height)
        }) { (success: Bool) in
            if success {
                UIView.animate(withDuration: 0.5) {
                    theButton.bounds = bounds
                }
            }
        }
        
        
        if cityCategory?.isEmpty ?? false && reachability.connection != .unavailable{
            if UserDefaults.standard.double(forKey: "Lat") != 0 && UserDefaults.standard.double(forKey: "Lon") != 0{
                if UserDefaults.standard.bool(forKey: "Fah") == true {
                    sender.setTitle("ºF", for: .normal)
                    UserDefaults.standard.set(false, forKey: "Fah")
                    UserDefaults.standard.set(false, forKey: "TempUnit")
                } else {
                    sender.setTitle("ºC", for: .normal)
                    UserDefaults.standard.set(true, forKey: "Fah")
                    UserDefaults.standard.set(true, forKey: "TempUnit")
                }
                tableView.reloadData()
            }
            return
        }
        if let city = cityCategory?[0] {
            if city.information?.fahrenheit == true{
                sender.setTitle("ºF", for: .normal)
                for eachCity in cityCategory!{
                    try! realm.write {
                        eachCity.information?.fahrenheit = false
                    }
                }
                UserDefaults.standard.set(false, forKey: "TempUnit")
            } else {
                sender.setTitle("ºC", for: .normal)
                for eachCity in cityCategory!{
                    try! realm.write {
                        eachCity.information?.fahrenheit = true
                    }
                }
                UserDefaults.standard.set(true, forKey: "TempUnit")
            }
            tableView.reloadData()
            
        } else {
            sender.setTitle("ºC", for: .normal)
        }
    }
    
    func checkTempUnit(){
        if cityCategory?.isEmpty == true{
            return
        }
        
        if let city = cityCategory?[0] {
            let tempUnit = UserDefaults.standard.bool(forKey: "TempUnit")
            if city.information?.fahrenheit != tempUnit{
                for eachCity in cityCategory!{
                    try! realm.write{
                        eachCity.information?.fahrenheit = tempUnit
                    }

                }
            }
        }
    }
    
    
    //MARK: - Data Manipulation Methods
    
    func save(weather: WeatherModel){
        DispatchQueue.main.async {
            do {
                try self.realm.write{
                    self.realm.add(weather)
                }
            } catch {
                print("Error adding data, \(error)")
            }
        self.tableView.reloadData()
        }
        
    }
    
    @objc func loadCity(){
        //dispatchGroup.enter()
        cityCategory = realm.objects(WeatherModel.self)
        var citiesLatLon = [CityModel]()
        if let cities = cityCategory {
            for city in cities{
                var cityLatLon = CityModel()
                cityLatLon.latitude = city.information?.latitude ?? 0
                cityLatLon.longitude = city.information?.longitude ?? 0
                citiesLatLon.append(cityLatLon)
            }
            deleteObjs()
            
            //
            
            let userLat = UserDefaults.standard.double(forKey: "Lat")
            let userLon = UserDefaults.standard.double(forKey: "Lon")
            
            var dataExisted = false
            print("Lat: ", userLat)
            print("Lon: ", userLon)
            
            if userLat == 0 && userLon == 0{
                dataExisted = true
            } else {
                for city in citiesLatLon{
                    if userLat == city.latitude && userLon == city.longitude{
                        dataExisted = true
                    }
                }
            }
            
            if dataExisted == false{
                var userCurrentCity = CityModel()
                userCurrentCity.latitude = userLat
                userCurrentCity.longitude = userLon
                citiesLatLon.insert(userCurrentCity, at: 0)
                
            }
            
//            if CLLocationManager.authorizationStatus() != .denied{//
//                view.addSubview(VW_overlay)
//                activityIndicatorView.startAnimating()
//            }
            
            for cityLatLon in citiesLatLon{
                weatherManager.fetchWeather(latitude: cityLatLon.latitude, longitude: cityLatLon.longitude)
            }
        }

        tableView.reloadData()
    }
    
    func deleteObjs(){
        let realm = try! Realm()
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print(error)
        }
    }
    
    func checkDayTime(_ indexPathRow: Int) -> Bool{
        let currentTime = cityCategory?[indexPathRow].information?.currentUTCTime ?? 0
        let sunSetTime = cityCategory?[indexPathRow].information?.sunSet ?? 0
        let sunRiseTime = cityCategory?[indexPathRow].information?.sunRise ?? 0
        
        if currentTime >= sunSetTime{
            return false
        } else if currentTime <= sunRiseTime{
            return false
        } else {
            return true
        }
    }
    
    func checkDayTime() -> Bool {
        let currentTime = UserDefaults.standard.double(forKey: "CurrentUTC")
        let sunSetTime = UserDefaults.standard.double(forKey: "SunSet")
        let sunRiseTime = UserDefaults.standard.double(forKey: "SunRise")
        
        if currentTime >= sunSetTime{
            return false
        } else if currentTime <= sunRiseTime{
            return false
        } else {
            return true
        }
    }
    
}

extension LocationViewController: UITableViewDataSource{
    //MARK: - Table View DataSources Method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        var checker : String
        //checker = UserDefaults.standard.
        if CLLocationManager.authorizationStatus() != .denied && (UserDefaults.standard.double(forKey: "Lat") != 0 && UserDefaults.standard.double(forKey: "Lon") != 0) && reachability.connection != .unavailable{
            return (cityCategory?.count ?? 0) + 1
        } else {
            return cityCategory?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationWeatherCell", for: indexPath) as! LocationWeatherTableViewCell
        cell.gooeyCellDelegate = self
        let randomInt = Int.random(in: 1..<5)
        var temperatureInt = Int()
        
        if CLLocationManager.authorizationStatus() != .denied{
            if indexPath.row == 0 {
                cell.locationSymbol.isHidden = false
                if checkDayTime() == false {
                    cell.backGroundImage.image = #imageLiteral(resourceName: "45")
                    cell.sunOrMoonImage.image = UIImage(named: "Moon" + String(randomInt))
                } else {
                    cell.backGroundImage.image = #imageLiteral(resourceName: "ye")
                    cell.sunOrMoonImage.image = UIImage(named: "Sun" + String(randomInt))
                }
                cell.cityLabel.text = UserDefaults.standard.string(forKey: "Name")
                let temperatureDouble = UserDefaults.standard.double(forKey: "Temp")
                temperatureInt = Int(temperatureDouble)
            } else {
                cell.locationSymbol.isHidden = true
                if checkDayTime(indexPath.row - 1) == false{
                    cell.backGroundImage.image = #imageLiteral(resourceName: "45")
                    cell.sunOrMoonImage.image = UIImage(named: "Moon" + String(randomInt))
                } else {
                    cell.backGroundImage.image = #imageLiteral(resourceName: "ye")
                    cell.sunOrMoonImage.image = UIImage(named: "Sun" + String(randomInt))
                }
                
                cell.cityLabel.text = self.cityCategory?[indexPath.row - 1].cityName ?? "No city added"
                let temperatureDouble = self.cityCategory?[indexPath.row - 1].information?.temperature ?? 0
                temperatureInt = Int(temperatureDouble)
            }
            
        } else {
            cell.locationSymbol.isHidden = true
            if checkDayTime(indexPath.row) == false{
                cell.backGroundImage.image = #imageLiteral(resourceName: "45")
                cell.sunOrMoonImage.image = UIImage(named: "Moon" + String(randomInt))
            } else {
                cell.backGroundImage.image = #imageLiteral(resourceName: "ye")
                cell.sunOrMoonImage.image = UIImage(named: "Sun" + String(randomInt))
            }
            
            cell.cityLabel.text = self.cityCategory?[indexPath.row].cityName ?? "No city added"
            let temperatureDouble = self.cityCategory?[indexPath.row].information?.temperature ?? 0
            temperatureInt = Int(temperatureDouble)
        }
        
        if UserDefaults.standard.bool(forKey: "TempUnit") == true {
            cell.temperatureLabel.text = String(temperatureInt) + "ºF"
        } else {
            cell.temperatureLabel.text = String(((temperatureInt - 32) * 5) / 9) + "ºC"
        }
            
        return cell
        
    }
}

extension LocationViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let infoController = storyboard.instantiateViewController(identifier: "InfoVC") as! InformationViewController
        infoController.modalPresentationStyle = .fullScreen
        if CLLocationManager.authorizationStatus() != .denied{
            if indexPath.row == 0{
                let userCurrentCity = WeatherModel()
                userCurrentCity.information = WeatherInformation()
                userCurrentCity.cityName = UserDefaults.standard.string(forKey: "Name")!
                userCurrentCity.information?.temperature = UserDefaults.standard.double(forKey: "Temp")
                userCurrentCity.information?.humidity = UserDefaults.standard.double(forKey: "Humid")
                userCurrentCity.information?.pressure = UserDefaults.standard.double(forKey: "Pressure")
                userCurrentCity.information?.windSpeed = UserDefaults.standard.double(forKey: "Wind")
                userCurrentCity.information?.currentUTCTime = UserDefaults.standard.integer(forKey: "CurrentUTC")
                userCurrentCity.information?.sunRise = UserDefaults.standard.integer(forKey: "SunRise")
                userCurrentCity.information?.sunSet = UserDefaults.standard.integer(forKey: "SunSet")
                userCurrentCity.information?.timeZone = UserDefaults.standard.integer(forKey: "TimeZone")
                userCurrentCity.information?.conditionId = UserDefaults.standard.integer(forKey: "ConID")
                infoController.selectedLocation = userCurrentCity
                infoController.checkDayOrNight = checkDayTime()
            } else {
                infoController.selectedLocation = cityCategory?[indexPath.row - 1]
                infoController.checkDayOrNight = checkDayTime(indexPath.row - 1)
            }
        }   else {
            infoController.selectedLocation = cityCategory?[indexPath.row]
            infoController.checkDayOrNight = checkDayTime(indexPath.row)
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.present(infoController, animated: true, completion: nil)
    }
    
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        if CLLocationManager.locationServicesEnabled(){
//            if indexPath.row == 0{
//                return false
//            } else {
//                return true
//            }
//        } else {
//            return true
//        }
//
//    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if CLLocationManager.locationServicesEnabled(){
//            if (editingStyle == UITableViewCell.EditingStyle.delete) {
//                try! realm.write {
//                    realm.delete(cityCategory![indexPath.row - 1].information!)
//                    realm.delete(cityCategory![indexPath.row - 1])
//                }
//                tableView.reloadData()
//            }
//        } else {
//            if (editingStyle == UITableViewCell.EditingStyle.delete) {
//                try! realm.write {
//                    realm.delete(cityCategory![indexPath.row].information!)
//                    realm.delete(cityCategory![indexPath.row])
//                }
//                tableView.reloadData()
//            }
//        }
//    }

}

extension LocationViewController: WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        weather.information?.fahrenheit = UserDefaults.standard.bool(forKey: "TempUnit")
        if weather.information?.latitude == UserDefaults.standard.double(forKey: "Lat") && weather.information?.longitude == UserDefaults.standard.double(forKey: "Lon"){
            UserDefaults.standard.set(weather.cityName, forKey: "Name")
            UserDefaults.standard.set(weather.information?.temperature, forKey: "Temp")
            UserDefaults.standard.set(weather.information?.humidity, forKey: "Humid")
            UserDefaults.standard.set(weather.information?.pressure, forKey: "Pressure")
            UserDefaults.standard.set(weather.information?.windSpeed, forKey: "Wind")
            UserDefaults.standard.set(weather.information?.currentUTCTime, forKey: "CurrentUTC")
            UserDefaults.standard.set(weather.information?.sunRise, forKey: "SunRise")
            UserDefaults.standard.set(weather.information?.sunSet, forKey: "SunSet")
            UserDefaults.standard.set(weather.information?.timeZone, forKey: "TimeZone")
            UserDefaults.standard.set(weather.information?.conditionId, forKey: "ConID")
            UserDefaults.standard.set(weather.information?.fahrenheit, forKey: "Fah")
            
            isUserDefaultSet = true
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.animationView?.isHidden = true
//                self.activityIndicatorView.stopAnimating()
//                self.VW_overlay.isHidden = true
            }
            
        } else {
            self.save(weather: weather)
            DispatchQueue.main.async{
//                self.activityIndicatorView.stopAnimating()
//                self.VW_overlay.isHidden = true
            }
        }
        
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}

extension LocationViewController: CityAddViewControllerDelegate{
    func didUpdateCityLatLon(cityLatLon: CityModel) {
        var cityWasAdded = false

        DispatchQueue.main.async {
            let cities = self.cityCategory!
            for city in cities{
                let lon = city.information?.longitude
                let lat = city.information?.latitude
                if cityLatLon.latitude == lat && cityLatLon.longitude == lon{
                    cityWasAdded = true
                    return
                }
            }
            if cityWasAdded == false {
//                self.VW_overlay.isHidden = false
//                self.activityIndicatorView.startAnimating()
                self.weatherManager.fetchWeather(latitude: cityLatLon.latitude, longitude: cityLatLon.longitude)
            } else {
                print("The city was added.")
            }
        }
    }
}

extension LocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            
            UserDefaults.standard.set(lat, forKey: "Lat")
            UserDefaults.standard.set(lon, forKey: "Lon")
            loadCity()
        }
//        self.activityIndicatorView.stopAnimating()
//        self.VW_overlay.isHidden = true
        print("Got location data")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways{
            if CLLocationManager.locationServicesEnabled(){
                self.animationView?.isHidden = false
//                self.activityIndicatorView.startAnimating()
//                self.VW_overlay.isHidden = false
                locationManager.requestLocation()
            }
        } else if status == .denied{
//            self.activityIndicatorView.stopAnimating()
//            self.VW_overlay.isHidden = true
            self.animationView?.isHidden = true
        }
        
        
    }
}

extension LocationViewController: GooeyCellDelegate{
    func gooeyCellActionConfig(for cell: UITableViewCell, direction: GooeyEffect.Direction) -> GooeyEffectTableViewCell.ActionConfig? {
        let color = #colorLiteral(red: 0.3019607843, green: 0.4980392157, blue: 0.3921568627, alpha: 1)
        let image = direction == .toLeft ? #imageLiteral(resourceName: "image_cross") : #imageLiteral(resourceName: "image_mark")
        let isCellDeletingAction = direction == .toLeft

        let effectConfig = GooeyEffect.Config(color: color,image: image)
        
        let actionConfig = GooeyEffectTableViewCell.ActionConfig(effectConfig: effectConfig,
                                                                 isCellDeletingAction: isCellDeletingAction)
        return actionConfig
    }
    
    func gooeyCellActionTriggered(for cell: UITableViewCell, direction: GooeyEffect.Direction) {
       switch direction {
         case .toLeft:
             removeCell(cell)
         case .toRight:
             break
         }
    }
    
    private func removeCell(_ cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        if indexPath.row != 0 {
            if CLLocationManager.authorizationStatus() != .denied{
                try! realm.write {
                    realm.delete(cityCategory![indexPath.row - 1].information!)
                    realm.delete(cityCategory![indexPath.row - 1])
                }
            } else {
                try! realm.write {
                    realm.delete(cityCategory![indexPath.row].information!)
                    realm.delete(cityCategory![indexPath.row])
                }
                
            }
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        } else {
            if CLLocationManager.authorizationStatus() != .denied{
                tableView.reloadData()
                return
            } else {
                try! realm.write {
                    realm.delete(cityCategory![indexPath.row].information!)
                    realm.delete(cityCategory![indexPath.row])
                }
                
            }
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
        
    }
}
