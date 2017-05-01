//
//  SearchController.swift
//  Wager
//
//  Created by Michael Swart on 4/24/17.
//
//
import Foundation
import Firebase

class SearchController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  let USERS_TABLE = 1
  let BETS_TABLE = 2
  
    
  @IBOutlet weak var tablePickingButtons: UISegmentedControl!
  @IBOutlet weak var searchTableView: UITableView!
  @IBOutlet weak var SearchQuery: UITextField!
  
  var items: [Profile] = []
  var b_items: [BetItem] = []
  var tablePicked = 1
  var selectedIndex: Int = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    searchTableView.delegate = self
    searchTableView.dataSource = self
    reloadRows()
  }
  
  func reloadRows(){
    var searchStr = SearchQuery.text!
    if (searchStr == ""){
      searchTableView.isHidden = true
      return
    }
    searchTableView.isHidden = false
    
    searchStr = searchStr.uppercased()
    if (self.tablePicked == USERS_TABLE) {
      let ref = FIRDatabase.database().reference(withPath: "Profiles")
      var newItems: [Profile] = []
      
      ref.observe(.value, with: { snapshot in
        for item in snapshot.children {
          let profItem = Profile(snapshot: item as! FIRDataSnapshot)
          var nameStr = profItem.firstName + " " + profItem.lastName
          nameStr = nameStr.uppercased()
          var usernameStr = "@" + profItem.username
          usernameStr = usernameStr.uppercased()
          if (nameStr.range(of: searchStr) != nil){
            newItems.append(profItem)
          }
          else if (usernameStr.range(of: searchStr) != nil){
            newItems.append(profItem)
          }
        }
        self.items = newItems
        self.searchTableView.reloadData()
      })
    }
    else if (self.tablePicked == BETS_TABLE) {
      let ref = FIRDatabase.database().reference(withPath: "Bets")
      var newItems: [BetItem] = []
      
      ref.observe(.value, with: { snapshot in
        for item in snapshot.children {
          let bItem = BetItem(snapshot: item as! FIRDataSnapshot)
          var nameStr = bItem.name
          nameStr = nameStr.uppercased()
          if (nameStr.range(of: searchStr) != nil){
            newItems.append(bItem)
          }
          var descStr = bItem.description
          descStr = descStr.uppercased()
          if (descStr.range(of: searchStr) != nil){
            newItems.append(bItem)
          }
        }
        self.b_items = newItems
        self.searchTableView.reloadData()
      })
    }
    else {print("Table Picker is Wrong"); return}
    
  }
  
  // MARK: TABLE VIEW DELEGATE AND DATASOURCE
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if (self.tablePicked == USERS_TABLE) {return items.count}
    else if (self.tablePicked == BETS_TABLE) {return b_items.count}
    else {return 0}
  }
  
  func numberOfSections(in itemsTableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if (self.tablePicked == USERS_TABLE) {
      let item = items[indexPath.row]
      let cell = self.searchTableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell") as! SearchTableViewCell
      cell.usernameLabel.text = "@" + item.username
      cell.nameLabel.text = item.firstName + " " + item.lastName
      return cell
    }
    else if (self.tablePicked == BETS_TABLE) {
      let item = b_items[indexPath.row]
      let cell = self.searchTableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell") as! SearchTableViewCell
      cell.usernameLabel.text = item.description
      cell.nameLabel.text = item.name
      return cell
    }
    let cell = self.searchTableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell") as! SearchTableViewCell
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if(self.tablePicked == USERS_TABLE) {
      self.performSegue(withIdentifier: "toProfile", sender: self);
    }
    else if (self.tablePicked == BETS_TABLE) {
      self.performSegue(withIdentifier: "toBet", sender: self);
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if (segue.identifier == "toBet") {
      let vc = segue.destination as! BetViewController
      if let indexPath = self.searchTableView.indexPathForSelectedRow {
        vc.bet = b_items[indexPath.row]
      }
    }
    else if (segue.identifier == "toProfile") {
      let vc = segue.destination as! ProfileViewController
      if let indexPath = self.searchTableView.indexPathForSelectedRow {
        vc.profile = items[indexPath.row]
      }
    }
  }

  
  @IBAction func SearchButtonPressed(_ sender: Any) {
    reloadRows()
  }
  
  @IBAction func tablePicker(_ sender: Any) {
    switch tablePickingButtons.selectedSegmentIndex
    {
    case 0:
      self.tablePicked = USERS_TABLE
      b_items = []
      reloadRows()
      
    case 1:
      self.tablePicked = BETS_TABLE
      items = []
      reloadRows()
      
    default:
      break
    }
  }
  
}
