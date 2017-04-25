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
  
  @IBOutlet weak var searchTableView: UITableView!
  @IBOutlet weak var SearchQuery: UITextField!
  
  var items: [Profile] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    searchTableView.delegate = self
    searchTableView.dataSource = self
    reloadRows()
    
    //itemsTableView.dataSource
  }
  
  func reloadRows(){
    var searchStr = SearchQuery.text!
    if (searchStr == ""){return}
    searchStr = searchStr.uppercased()

    let ref = FIRDatabase.database().reference(withPath: "Profiles")
    var newItems: [Profile] = []
    
    ref.observe(.value, with: { snapshot in
      for item in snapshot.children {
        let profItem = Profile(snapshot: item as! FIRDataSnapshot)
        var nameStr = profItem.firstName + " " + profItem.lastName
        nameStr = nameStr.uppercased()
        if (nameStr.range(of: searchStr) != nil ){
          newItems.append(profItem)
        }
      }
      self.items = newItems
      self.searchTableView.reloadData()
    })
  }
  
  // MARK: TABLE VIEW DELEGATE AND DATASOURCE
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  func numberOfSections(in itemsTableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let item = items[indexPath.row]
    //print(String(indexPath.row) + " " + item.firstName + " " + item.lastName)
    let cell = self.searchTableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell") as! SearchTableViewCell
    
    cell.usernameLabel.text = "@" + item.username
    cell.nameLabel.text = item.firstName + " " + item.lastName
    return cell
  }
  
  @IBAction func SearchButtonPressed(_ sender: Any) {
    reloadRows()
  }
}
