//
//  CityAddViewController.swift
//  Weather
//
//  Created by horkimlong on 6/23/20.
//  Copyright © 2020 horkimlong. All rights reserved.
//

import Foundation
import UIKit

protocol CityAddViewControllerDelegate {
    func didUpdateCityLatLon(cityLatLon: CityModel)
}

class CityAddViewController: UIViewController {
    
    var locations = [LocationModel]()
    var locationManager = LocationManager()
    
    var cityManager = CityManager()
    //var cityInfo = CityModel()
    
    var delegate : CityAddViewControllerDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        cityManager.delegate = self
        //self.view.backgroundColor = UIColor.clear
        //self.modalPresentationStyle = .overCurrentContext
    }
}

extension CityAddViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FullCityNameCell", for: indexPath) as! FullCityNameTableViewCell
        cell.fullCityNameLabel.text = locations[indexPath.row].fullName
        //cell.backgroundColor = UIColor.clear
        return cell
    }
    
    
}

extension CityAddViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cityInformationLink = locations[indexPath.row].link
        cityManager.fetchCityInfo(link: cityInformationLink)
    }
}

extension CityAddViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.count >= 3 {
            if let safeText = searchBar.text{
                locationManager.fetchLocation(str: safeText)
            }
        } else {
            locations.removeAll()
            tableView.reloadData()
        }
    }
}

extension CityAddViewController: LocationManagerDelegate {
    func didUpdateLocation(_ locationManager: LocationManager, location: [LocationModel]) {
        locations = location
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func didFailWithError(error: Error) {
        print("In LocationManagerDelegate -> \(error)")
    }
}

extension CityAddViewController: CityManagerDelegate {
    func didUpdateCity(_ cityManager: CityManager, city: CityModel) {
        delegate?.didUpdateCityLatLon(cityLatLon: city)
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func didFailWithErrorForCity(error: Error) {
        print("In CityManagerDelegate\(error)")
    }
}
