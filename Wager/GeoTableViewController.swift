//
//  GeoTableViewController.swift
//  Wager
//
//  Created by Tyler Kaye on 4/28/17.
//
//

import UIKit
import Firebase
import GeoFire
import CoreLocation

class GeoTableViewController: UITableViewController {
  let BET_TYPE_ALL = 0
  let BET_TYPE_POSED = 1
  let BET_TYPE_ACTIVE = 2
  let BET_TYPE_COMPLETED = 3
  var betType = 0


  //@IBOutlet weak var ChannelsButton: UIButton!
  
//  var channelName = ""
//  @IBAction func ChannelSelect(_ sender: Any) {
//    
//    let alertController = UIAlertController(title: "Pick A Channel", message: "select one", preferredStyle: .alert)
//    present(alertController, animated: true, completion: nil)
//    
//    //all channels
//    let callAll = UIAlertAction(title: "All", style: .default, handler: {
//      action in
//      self.channelName = ""
//      self.ChannelsButton.setTitle("All", for: .normal)
//      self.reloadRows()
//    }
//    )
//    alertController.addAction(callAll)
//    
//    //handle individual channels
//    for item in self.channels {
//      let newVal = UIAlertAction(title: item, style: .default, handler: {
//        action in
//        self.channelName = item
//        self.ChannelsButton.setTitle(item, for: .normal)
//        self.reloadRows()
//      })
//      alertController.addAction(newVal)
//    }
//    
//    //cancel
//    let callCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
//    alertController.addAction(callCancel)
//  }
  

//  @IBOutlet weak var TypeButton: UIButton!
//  @IBAction func WagerTypeSetter(_ sender: Any) {
//    
//    let alertController = UIAlertController(title: "Pick A Bet Type", message: "select one", preferredStyle: .alert)
//    
//    /*let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)*/
//    
//    present(alertController, animated: true, completion: nil)
//    
//    let callAll = UIAlertAction(title: "All Bet Types", style: .default, handler: {
//      action in
//      self.betType = self.BET_TYPE_ALL
//      self.TypeButton.setTitle("All Bet Types", for: .normal)
//      self.reloadRows()
//    }
//    )
//    alertController.addAction(callAll)
//    
//    let callPosed = UIAlertAction(title: "Posed Bets", style: .default, handler: {
//      action in
//      self.betType = self.BET_TYPE_POSED
//      self.TypeButton.setTitle("Posed Bets", for: .normal)
//      self.reloadRows()
//    }
//    )
//    alertController.addAction(callPosed)
//    
//    let callCurrent = UIAlertAction(title: "Active Bets", style: .default, handler: {
//      action in
//      self.betType = self.BET_TYPE_ACTIVE
//      self.TypeButton.setTitle("Active Bets", for: .normal)
//      self.reloadRows()
//    }
//    )
//    alertController.addAction(callCurrent)
//    
//    let callComplete = UIAlertAction(title: "Completed Bets", style: .default, handler: {
//      action in
//      self.betType = self.BET_TYPE_COMPLETED
//      self.TypeButton.setTitle("Completed Bets", for: .normal)
//      self.reloadRows()
//    }
//    )
//    alertController.addAction(callComplete)
//    
//    //cancel
//    let callCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
//    alertController.addAction(callCancel)
//    
//  }

  // MARK: Constants
  let listToUsers = "ListToUsers"
  
  // MARK: Properties
  let ref = FIRDatabase.database().reference(withPath: "Bets")
  let refChannel = FIRDatabase.database().reference(withPath: "Categories")
  let pRef = FIRDatabase.database().reference(withPath: "Profiles")
  
  var items: [BetItem] = []
  var channels: [String] = []
  var user: User!
  var userCountBarButtonItem: UIBarButtonItem!
  var selectedBet: BetItem?
  var profile: Profile?



    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        tableView.allowsMultipleSelectionDuringEditing = false
        refChannel.observe(.value, with: { snapshot in
          for item in snapshot.children {
            let currCat = item as! FIRDataSnapshot
            let snapshotValue = currCat.value as! String
            self.channels.append(snapshotValue)
          }
        })
      reloadRows()
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
  
  func reloadRows(){
    var new_ref = ref.queryOrdered(byChild: "category")
    //if (channelName != "") {new_ref = ref.queryOrdered(byChild: "category").queryEqual(toValue: channelName)}
    new_ref.observe(.value, with: { snapshot in
      var newItems: [BetItem] = []
      
      for item in snapshot.children {
        let betItem = BetItem(snapshot: item as! FIRDataSnapshot)
        if (self.betType == self.BET_TYPE_ALL) {newItems.append(betItem) }
        else if(self.betType == self.BET_TYPE_POSED && !betItem.accepted) {newItems.append(betItem) }
        else if(self.betType == self.BET_TYPE_ACTIVE && betItem.accepted && !betItem.completed) {newItems.append(betItem) }
        else if(self.betType == self.BET_TYPE_COMPLETED && betItem.completed) {newItems.append(betItem) }
      }
      self.items = newItems.sorted{ $0.date_opened > $1.date_opened }
      
      self.tableView.reloadData()
    })
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! GeoBetTableViewCell
    let betItem = items[indexPath.row]
    
    cell.betNameLabel.text = betItem.name
    cell.betChallengerLabel.text = betItem.challenger_name
    cell.betAmountLabel.text = String(format: "$%.2f", betItem.amount)
    
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
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
