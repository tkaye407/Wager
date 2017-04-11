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
  let firstName: String
  let lastName: String
  let email: String
  let pnl: Float
  //let picture: UIImage
  let age: Int
  let venmoID: String
  let gender: String
  let username: String

  init(firstName: String = "FirstName", lastName: String = "LastName", email: String = "email", pnl: Float = 0.0,  age: Int = 0, venmoID: String = "",  gender: String = "", key: String = "", userID: String = "", username: String = "" ) {
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
  }
  
  init(snapshot: FIRDataSnapshot) {
    key = snapshot.key
    let snapshotValue = snapshot.value as! [String: AnyObject]
    userID    = snapshotValue["userID"] as! String
    firstName = snapshotValue["firstName"] as! String
    lastName  = snapshotValue["lastName"] as! String
    email     = snapshotValue["email"] as! String
    pnl       = snapshotValue["pnl"] as! Float
    age       = snapshotValue["age"] as! Int
    venmoID   = snapshotValue["venmoID"] as! String
    gender    = snapshotValue["gender"] as! String
    username  = snapshotValue["username"] as! String
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
      "username":   username
    ]
  }
  
}

