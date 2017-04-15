  //
//  Profile.swift
//  Grocr
//
//  Created by Tyler Kaye on 4/7/17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Foundation
import Firebase

struct Profile {
  
  let key: String
  let userID: String
  var firstName: String
  var lastName: String
  var email: String
  var pnl: Float
  //let picture: UIImage
  var age: Int
  var venmoID: String
  var gender: String
  var username: String
  var rating: Float
  var numRatings: Int

  init(firstName: String = "FirstName", lastName: String = "LastName", email: String = "email", pnl: Float = 0.0,  age: Int = 0, venmoID: String = "",  gender: String = "", key: String = "", userID: String = "", username: String = "", rating: Float = 5.0, numRatings: Int = 1) {
      self.userID = userID
      self.key = key
      self.firstName = firstName
      self.lastName = lastName
      self.email = email
      self.pnl = pnl
      //self.picture = picture
      self.age = age
      self.venmoID = venmoID
      self.gender = gender
      self.username = username
      self.numRatings = numRatings
      self.rating = rating
  }
  
  init(snapshot: FIRDataSnapshot) {
    key = snapshot.key
    let snapshotValue = snapshot.value as! [String: AnyObject]
    userID      = snapshotValue["userID"] as! String
    firstName   = snapshotValue["firstName"] as! String
    lastName    = snapshotValue["lastName"] as! String
    email       = snapshotValue["email"] as! String
    pnl         = snapshotValue["pnl"] as! Float
    age         = snapshotValue["age"] as! Int
    venmoID     = snapshotValue["venmoID"] as! String
    gender      = snapshotValue["gender"] as! String
    username    = snapshotValue["username"] as! String
    rating      = snapshotValue["rating"] as! Float
    numRatings  = snapshotValue["num_ratings"] as! Int
    
    //picture   =
  }
  
  
  func toAnyObject() -> Any {
    return [
      "userID":     userID,
      "firstName":  firstName,
      "lastName":   lastName,
      "email":      email,
      "pnl":        pnl,
      "age":        age,
      "venmoID":    venmoID,
      "gender":     gender,
      "username":   username,
      "rating":     rating,
      "num_ratings": numRatings
    ]
  }
  
}

