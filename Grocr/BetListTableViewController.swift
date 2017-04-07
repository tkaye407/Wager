//
//  BetListTableViewController.swift
//  WagerApp
//
//  Created by Tyler Kaye, Michael Swart, Richard Bush, and William Chance on 4/2/17.
//

import UIKit
import Firebase

class BetListTableViewController: UITableViewController {

    @IBOutlet weak var ChannelsButton: UIButton!
  
  var channelName = ""
    @IBAction func ChannelSelect(_ sender: Any) {
      
      let alertController = UIAlertController(title: "Pick A Channel", message: "select one", preferredStyle: .alert)
      
      let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
      
      present(alertController, animated: true, completion: nil)
      
      //all channels
      let callAll = UIAlertAction(title: "All", style: .default, handler: {
        action in
        self.channelName = ""
        self.ChannelsButton.setTitle("All", for: .normal)
        self.reloadRows()
      }
      )
      alertController.addAction(callAll)
      
      //handle individual channels
      for item in self.channels {
        let newVal = UIAlertAction(title: item, style: .default, handler: {
          action in
          self.channelName = item
            self.ChannelsButton.setTitle(item, for: .normal)
          self.reloadRows()
        })
        alertController.addAction(newVal)
      }
      
      //cancel
      let callCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
      alertController.addAction(callCancel)
    }
  
  
  
    @IBOutlet weak var TypeButton: UIButton!
    var betType = "all"
    @IBAction func WagerTypeSetter(_ sender: Any) {
      
      let alertController = UIAlertController(title: "Pick A Bet Type", message: "select one", preferredStyle: .alert)
      
      let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
      
      present(alertController, animated: true, completion: nil)
      
      let callAll = UIAlertAction(title: "All Bet Types", style: .default, handler: {
        action in
        self.betType = "all"
        self.TypeButton.setTitle("All Bet Types", for: .normal)
        self.reloadRows()
      }
      )
      alertController.addAction(callAll)
      
      let callPosed = UIAlertAction(title: "Posed Bets", style: .default, handler: {
        action in
        self.betType = "posed"
        self.TypeButton.setTitle("Posed Bets", for: .normal)
        self.reloadRows()
      }
      )
      alertController.addAction(callPosed)
      
      let callCurrent = UIAlertAction(title: "Active Bets", style: .default, handler: {
        action in
        self.betType = "active"
        self.TypeButton.setTitle("Active Bets", for: .normal)
        self.reloadRows()
      }
      )
      alertController.addAction(callCurrent)
      
      let callComplete = UIAlertAction(title: "Completed Bets", style: .default, handler: {
        action in
        self.betType = "complete"
        self.TypeButton.setTitle("Completed Bets", for: .normal)
        self.reloadRows()
      }
      )
      alertController.addAction(callComplete)
      
      //cancel
      let callCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
      alertController.addAction(callCancel)
      
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
  var selectedBet: BetItem?
  
  // MARK: UIViewController Lifecycle
  
  func reloadRows(){
    var new_ref = ref.queryOrdered(byChild: "category")
    if (channelName != "") {new_ref = ref.queryOrdered(byChild: "category").queryEqual(toValue: channelName)}
    new_ref.observe(.value, with: { snapshot in
      var newItems: [BetItem] = []
      
      for item in snapshot.children {
        let betItem = BetItem(snapshot: item as! FIRDataSnapshot)
        if (self.betType == "all") {newItems.append(betItem) }
        else if(self.betType == "posed" && !betItem.completed) {newItems.append(betItem) }
        else if(self.betType == "active" && betItem.completed) {newItems.append(betItem) }
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
    //channels = []
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
    let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! BetTableViewCell
    let betItem = items[indexPath.row]
    
    cell.betNameLabel.text = betItem.name
    cell.betChallengerLabel.text = betItem.challenger
    cell.betAmountLabel.text = "$" + betItem.amount
    
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
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let indexPath = tableView.indexPathForSelectedRow!
    selectedBet = items[indexPath.row]
    self.performSegue(withIdentifier: "toIndividualBet", sender: self);
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if (segue.identifier == "toIndividualBet") {
        let vc = segue.destination as! BetViewController
        // Pass the selected object to the new view controller.
        if let indexPath = self.tableView.indexPathForSelectedRow {
          let selectedBet = items[indexPath.row]
          vc.bet = selectedBet
      }
    }
  }
}
