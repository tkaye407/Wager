//
//  BetItem.swift
//  WagerApp
//
//  Created by Tyler Kaye, Michael Swart, Richard Bush, and William Chance on 4/2/17.
//

import Foundation
import Firebase

struct BetItem {
  
  let ref: FIRDatabaseReference?
  
  let key: String
  let name: String
  let description: String
  let challenger_uid: String //this might change
  let challenger_name: String
  let challengee_uid: String //This might change
  let challengee_name: String
  let amount: Float
  var category: String
  let date_opened: Double
  let date_closed: Double
  
  var accepted: Bool
  var completed: Bool
  var confirmed: Bool
  var paid: Bool
  
  var winner: Bool //True means that challenger won
  var arbitration: Bool
  
  
  init(key: String = "", name: String, description: String, challenger_uid: String,
       challenger_name: String, date_opened: Double, date_closed: Double, category: String, amount: Float, challengee_uid: String = "", challengee_name: String = "", accepted: Bool = false, completed: Bool = false, confirmed: Bool = false, winner: Bool = true, arbitration: Bool = false) {
    self.ref = nil
    
    self.key = key
    self.name = name
    self.description = description
    self.challenger_uid = challenger_uid
    self.challenger_name = challenger_name
    self.challengee_uid = challengee_uid
    self.challengee_name = challengee_name
    self.amount = amount
    self.category = category
    self.date_opened = date_opened
    self.date_closed = date_closed
    
    self.accepted = accepted
    self.completed = completed
    self.confirmed = confirmed
    self.paid = false
    
    self.winner = winner
    self.arbitration = arbitration
  }
  
  init(snapshot: FIRDataSnapshot) {
    ref = snapshot.ref
    key = snapshot.key
    
    let snapshotValue = snapshot.value as! [String: AnyObject]
    
    name = snapshotValue["name"] as! String
    description = snapshotValue["description"] as! String
    challenger_uid = snapshotValue["challenger_uid"] as! String
    challenger_name = snapshotValue["challenger_name"] as! String
    challengee_uid = snapshotValue["challengee_uid"] as! String
    challengee_name = snapshotValue["challengee_name"] as! String
    amount = snapshotValue["amount"] as! Float
    category = snapshotValue["category"] as! String
    date_opened = snapshotValue["date_opened"] as! Double
    date_closed = snapshotValue["date_closed"] as! Double
    
    accepted = snapshotValue["accepted"] as! Bool
    completed = snapshotValue["completed"] as! Bool
    confirmed = snapshotValue["confirmed"] as! Bool
    paid = snapshotValue["paid"] as! Bool

    winner = snapshotValue["winner"] as! Bool
    arbitration = snapshotValue["arbitration"] as! Bool

  }
  
  func toAnyObject() -> Any {
    return [
      "name": name,
      "description": description,
      "challenger_uid": challenger_uid,
      "challenger_name": challenger_name,
      "challengee_uid": challengee_uid,
      "challengee_name": challengee_name,
      "amount": amount,
      "category": category,
      "date_opened": date_opened,
      "date_closed": date_closed,
      
      "accepted": accepted,
      "completed": completed,
      "confirmed": confirmed,
      "paid": paid,
      
      "winner": winner,
      "arbitration": arbitration
    ]
  }
  
}
