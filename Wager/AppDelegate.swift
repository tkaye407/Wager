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
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var user: User?
  var profile: Profile?
  var currLocation: CLLocation?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]? = [:]) -> Bool {
    UIApplication.shared.statusBarStyle = .lightContent
    FIRApp.configure()
    return true
  }

}

