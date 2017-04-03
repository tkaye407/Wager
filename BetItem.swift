//
//  BetItem.swift
//  Grocr
//
//  Created by Tyler Kaye on 4/2/17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Foundation
import Firebase

struct BetItem {
  
  let key: String
  let name: String
  let challenger: String
  //let challengee: String
  let ref: FIRDatabaseReference?
  var completed: Bool
  
  init(name: String, challenger: String, completed: Bool, key: String = "") {
    self.key = key
    self.name = name
    self.challenger = challenger
   // self.challengee = ""
    self.completed = completed
    self.ref = nil
  }
  
  init(snapshot: FIRDataSnapshot) {
    key = snapshot.key
    let snapshotValue = snapshot.value as! [String: AnyObject]
    name = snapshotValue["name"] as! String
    challenger = snapshotValue["challenger"] as! String
    completed = snapshotValue["completed"] as! Bool
    ref = snapshot.ref
   // challengee = ""
  }
  
  func toAnyObject() -> Any {
    return [
      "name": name,
      "challenger": challenger,
      "completed": completed
      //"challengee": challengee
    ]
  }
  
}
