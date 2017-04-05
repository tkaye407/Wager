//
//  BetListTableViewController.swift
//  WagerApp
//
//  Created by Tyler Kaye, Michael Swart, Richard Bush, and William Chance on 4/2/17.
//

import UIKit
import Firebase

class BetListTableViewController: UITableViewController {

  /*enum UIAlertControllerStyle : Int {
    case ActionSheet
    case Alert
    case Cancel
  }*/
  
  var channelName = ""
    @IBAction func ShowChannel(_ sender: Any) {
      
      let alertController = UIAlertController(title: "Pick A Channel", message: "select one", preferredStyle: .alert)
      
      let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
      
      present(alertController, animated: true, completion: nil)
      
      let callAll = UIAlertAction(title: "All", style: .default, handler: {
        action in
        self.channelName = ""
        self.viewDidLoad()
      }
      )
      alertController.addAction(callAll)
      var total = ""
      for item in self.channels {
        let newVal = UIAlertAction(title: item, style: .default, handler: {
          action in
          self.channelName = item
          self.reloadRows()
        })
        alertController.addAction(newVal)
      }
    }
  
  
  // MARK: Constants
  let listToUsers = "ListToUsers"
  
  // MARK: Properties 
  let ref = FIRDatabase.database().reference(withPath: "Bets")
  let refChannel = FIRDatabase.database().reference(withPath: "Categories")
  var items: [BetItem] = []
  var channels: [String] = []
  var user: User!
  var userCountBarButtonItem: UIBarButtonItem!
  
  // MARK: UIViewController Lifecycle
  
  func reloadRows(){
    var new_ref = ref.queryOrdered(byChild: "category")
    if (channelName != "") {new_ref = ref.queryOrdered(byChild: "category").queryEqual(toValue: channelName)}
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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.allowsMultipleSelectionDuringEditing = false
    channels = []
    refChannel.observe(.value, with: { snapshot in
      for item in snapshot.children {
        let currCat = item as! FIRDataSnapshot
        let snapshotValue = currCat.value as! String
        self.channels.append(snapshotValue)
      }
    })
    
    reloadRows()
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
