//
//  SearchController.swift
//  Wager
//
//  Created by Michael Swart on 4/24/17.
//
//

import Foundation
import Firebase

class SearchController: UIViewController {
  
  @IBOutlet weak var itemsTableView: UITableView!
  @IBOutlet weak var SearchQuery: UITextField!
  
  var items: [Profile] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    reloadRows()
  }
  
  func reloadRows(){
    var searchStr = SearchQuery.text!
    if (searchStr == ""){ return}
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
      self.itemsTableView.reloadData()
      for item in self.items {print(item.firstName + " " + item.lastName)}
      print("\n")
    })
  }
  
  // MARK: TABLE VIEW DELEGATE AND DATASOURCE
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let item = items[indexPath.row]
    print("HELLO" + item.firstName)
    let cell = self.itemsTableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell") as! SearchTableViewCell

    cell.usernameLabel.text = item.firstName + " " + item.lastName
    return cell
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  
  @IBAction func SearchButtonPressed(_ sender: Any) {
    reloadRows()
  }
}
