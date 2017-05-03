//
//  AppDelegate.swift
//  WagerApp
//
//  Created by Tyler Kaye, Michael Swart, Richard Bush, and William Chance on 4/2/17.
//

import UIKit
import Firebase
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

  var window: UIWindow?
  var user: User?
  var profile: Profile?
  var currLocation: CLLocation?
  let locationManager = CLLocationManager()
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]? = [:]) -> Bool {
    UIApplication.shared.statusBarStyle = .lightContent
    FIRApp.configure()
    self.locationManager.delegate = self
    locationManager.distanceFilter = 100.0
    locationManager.requestWhenInUseAuthorization()
    return true
  }
  
  
  
  func applicationWillResignActive(_ application: UIApplication) {
    print("Resigning")
    currLocation = nil
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    locationManager.requestLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.first {
      print("SETTING APP DELEGATE LOCATION")
      self.currLocation = location
    }
    
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Failed to find user's location: \(error.localizedDescription)")
  }

}

