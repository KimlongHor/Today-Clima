//
//  AppDelegate.swift
//  Weather
//
//  Created by horkimlong on 6/23/20.
//  Copyright © 2020 horkimlong. All rights reserved.
//

import UIKit
import RealmSwift
//import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{

//    var locationManager: CLLocationManager!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        do {
            let realm = try Realm()
        } catch {
            print("Error initialising new real\(error)")
        }
        
//        initializeLocationManager()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        UserDefaults.standard.removeObject(forKey: "Lat")
        UserDefaults.standard.removeObject(forKey: "Lon")
        UserDefaults.standard.removeObject(forKey: "Name")
        UserDefaults.standard.removeObject(forKey: "Temp")
        UserDefaults.standard.removeObject(forKey: "Humid")
        UserDefaults.standard.removeObject(forKey: "Pressure")
        UserDefaults.standard.removeObject(forKey: "Wind")
        UserDefaults.standard.removeObject(forKey: "CurrentUTC")
        UserDefaults.standard.removeObject(forKey: "SunRise")
        UserDefaults.standard.removeObject(forKey: "SunSet")
        UserDefaults.standard.removeObject(forKey: "TimeZone")
        UserDefaults.standard.removeObject(forKey: "ConID")
        UserDefaults.standard.removeObject(forKey: "Fah")
        print("->> ",UserDefaults.standard.double(forKey: "Lat"))
    }


}

