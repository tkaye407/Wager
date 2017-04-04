//
//  BetItem.swift
//  WagerApp
//
//  Created by Tyler Kaye, Michael Swart, Richard Bush, and William Chance on 4/2/17.
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
  let amount: String
  
  init(name: String, challenger: String, completed: Bool, key: String = "", amount: String = "0") {
    self.key = key
    self.name = name
    self.challenger = challenger
   // self.challengee = ""
    self.completed = completed
    self.ref = nil
    self.amount = amount
  }
  
  init(snapshot: FIRDataSnapshot) {
    key = snapshot.key
    let snapshotValue = snapshot.value as! [String: AnyObject]
    name = snapshotValue["name"] as! String
    challenger = snapshotValue["challenger"] as! String
    completed = snapshotValue["completed"] as! Bool
    ref = snapshot.ref
    amount = snapshotValue["amount"] as! String
   // challengee = ""
  }
  
  func toAnyObject() -> Any {
    return [
      "name": name,
      "challenger": challenger,
      "completed": completed,
      "amount": amount
      //"challengee": challengee
    ]
  }
  
}
