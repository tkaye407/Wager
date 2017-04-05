//
//  BetListTableViewController.swift
//  WagerApp
//
//  Created by Tyler Kaye, Michael Swart, Richard Bush, and William Chance on 4/2/17.
//

import UIKit
import Firebase

class BetListTableViewController: UITableViewController {

  // MARK: Constants
  let listToUsers = "ListToUsers"
  
  // MARK: Properties 
  let ref = FIRDatabase.database().reference(withPath: "Bets")
  var items: [BetItem] = []
  var user: User!
  var userCountBarButtonItem: UIBarButtonItem!
  
  // MARK: UIViewController Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.allowsMultipleSelectionDuringEditing = false
  
    
    user = User(uid: "FakeId", email: "hungry@person.food")
    
    let new_ref = ref.queryOrdered(byChild: "category")//.queryEqual(toValue: "school")
    new_ref.observe(.value, with: { snapshot in
      var newItems: [BetItem] = []
      
      
      for item in snapshot.children {
        let betItem = BetItem(snapshot: item as! FIRDataSnapshot)
        newItems.append(betItem)
      }
      self.items = newItems
      self.tableView.reloadData()
    })
    
    
    FIRAuth.auth()!.addStateDidChangeListener { auth, user in
      guard let user = user else { return }
      self.user = User(authData: user)
    }
  }
  
  // MARK: UITableView Delegate methods
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
    let betItem = items[indexPath.row]
    
    cell.textLabel?.text = betItem.name
    cell.detailTextLabel?.text = betItem.challenger
    cell.detailTextLabel?.text = betItem.amount
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      items.remove(at: indexPath.row)
      tableView.reloadData()
    }
  }

  
}
