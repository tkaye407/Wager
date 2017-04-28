//
//  Friend.swift
//  Wager
//
//  Created by Michael Swart on 4/28/17.
//
//

import Foundation
import Firebase

struct Friend {
  
  let ref: FIRDatabaseReference?
  let key: String
  let username: String
  
  
  init(user_uid: String, username: String) {
    self.ref = nil
    self.key = user_uid
    self.username = username
  }
  
  init(snapshot: FIRDataSnapshot) {
    ref = snapshot.ref
    key = snapshot.key
    
    let snapshotValue = snapshot.value as! [String: AnyObject]
    
    username = snapshotValue["username"] as! String
    
  }
  
  func toAnyObject() -> Any {
    return [
      "username": username
    ]
  }
  
}
