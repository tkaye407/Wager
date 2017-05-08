//
//  BetListTableViewController.swift
//
//  Created by Tyler Kaye, Michael Swart, Richard Bush, and William Chance on 4/2/17.
//

import UIKit
import Firebase
import GeoFire
import CoreLocation

class BetListTableViewController: UITableViewController {
  
    // MARK: Constants:
    let BET_TYPE_ALL = 0
    let BET_TYPE_POSED = 1
    let BET_TYPE_ACTIVE = 2
    let BET_TYPE_COMPLETED = 3
    let listToUsers = "ListToUsers"
  
    // MARK: filter variables
    var channelName = ""
    var friendsOnly = 0
    var geo = false
    var radius: Float = 5.0
    var betType = 1
    var fromFilter = false
    //private var setUpOnce = DispatchOnce()
    private let getCats = DispatchOnce()
  
    // MARK: Database references: 
    let ref = FIRDatabase.database().reference(withPath: "Bets")
    let refChannel = FIRDatabase.database().reference(withPath: "Categories")
    let pRef = FIRDatabase.database().reference(withPath: "Profiles")
    let fRef = FIRDatabase.database().reference(withPath: "Friends")

  
    // MARK: outlets
    @IBOutlet weak var ChannelsButton: UIButton!
    @IBOutlet weak var TypeButton: UIButton!
  
    // Mark: data arrays
    var items: [BetItem] = []
    var channels: [String] = []
  
    // MARK: placeholders for bet, profile, user
    var user: User!
    var selectedBet: BetItem?
    var profile: Profile?
  
  
  
    @IBAction func ChannelSelect(_ sender: Any) {
      self.performSegue(withIdentifier: "applyFilter", sender: self)
    }
  
  func isKeyPresentInUserDefaults(key: String) -> Bool {
    return UserDefaults.standard.object(forKey: key) != nil
  }
  
  func restOfViewDidLoad() {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    print(appDelegate.profile)
    let nc = NotificationCenter.default // Note that default is now a property, not a method call
    nc.addObserver(forName:Notification.Name(rawValue:"reloadData"),
                   object:nil, queue:nil) {
                    notification in
                    self.reloadRows()
    }
    
    if (!fromFilter) {
      print("GETTING USER DEFAULTS")
      if(isKeyPresentInUserDefaults(key: "dict")) {
        let result = UserDefaults.standard.value(forKey: "dict") as! [String:String]
        
        if let cat = result["category"] {
          if (cat == "All") {self.channelName = ""}
          else { self.channelName = cat }
        }
        if let rad = result["radius"] {
          if let radF = Float(rad) {
            self.radius = radF
          }
        }
        if let bt = result["type"] {
          let bti = (bt as NSString).integerValue
          self.betType = bti
        }
        if let friend = result["friend"] {
          let friendi = (friend as NSString).integerValue
          self.friendsOnly = friendi
        }
        if let geos = result["geo"] {
          let geosi = (geos as NSString).integerValue
          if (geosi == 1) {self.geo = true}
          else {self.geo = false}
        }
        print(result)
      }
    }
    
    tableView.allowsMultipleSelectionDuringEditing = false
    //channels = []
    if (appDelegate.categories.count <= 1) {
      print("GETTING CATEGORIES")
      channels.append("All")
      refChannel.observe(.value, with: { snapshot in
        for item in snapshot.children {
          let currCat = item as! FIRDataSnapshot
          let snapshotValue = currCat.value as! String
          self.channels.append(snapshotValue)
        }
        appDelegate.categories = self.channels
      })
    }
    
    
    FIRAuth.auth()!.addStateDidChangeListener { auth, user in
      guard let user = user else { return }
      self.user = User(authData: user)
      self.pRef.queryOrdered(byChild: "userID").queryEqual(toValue: user.uid).observe(.value, with:{ snapshot in
        for item in snapshot.children {
          self.profile = Profile(snapshot: item as! FIRDataSnapshot)
        }
        appDelegate.user = self.user
        appDelegate.profile = self.profile
        
        self.reloadRows()
      })
    }
    
    //self.TypeButton.isEnabled = false
    self.TypeButton.setTitle("Wagers", for: .normal)
  }
  
  // MARK: UIViewController Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    if (appDelegate.profile == nil) {
      print("Hello")
      FIRAuth.auth()!.addStateDidChangeListener { auth, user in
        guard let user = user else { return }
        self.user = User(authData: user)
        self.pRef.queryOrdered(byChild: "userID").queryEqual(toValue: user.uid).observe(.value, with:{ snapshot in
          for item in snapshot.children {
            self.profile = Profile(snapshot: item as! FIRDataSnapshot)
          }
          appDelegate.user = self.user
          appDelegate.profile = self.profile
          
          self.restOfViewDidLoad()
        })
      }
    }
    else {self.restOfViewDidLoad()}
  }

  // MARK: HELPER FUNCTIONS
  func reloadRows(){
    self.items = []
    var failed = true
    print((self.profile?.email)! + "\n\n")
    if (self.geo) {
      print("GEO")
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let currRef = FIRDatabase.database().reference().child("Bets")
      let geofireRef = FIRDatabase.database().reference().child("bet_locations")
      let geoFire = GeoFire(firebaseRef: geofireRef)
      let radius_km = self.radius * 1.6
      if let uLocation = appDelegate.currLocation {
        failed = false
        let circleQuery = geoFire?.query(at: uLocation, withRadius: Double(radius_km))
        self.items = []
        circleQuery?.observe(GFEventType.init(rawValue: 0)!, with: {(key: String!, location: CLLocation!) in
          currRef.child(key).observeSingleEvent(of: .value, with: { (snapshot) in
            if(!(snapshot.value is NSNull)) {
              let currBet = BetItem(snapshot: snapshot )
              if (self.friendsOnly == 1) { self.checkFriends(betItem: currBet) }
              else { self.checkBet(bet: currBet) }
            }
          })
        })
      }
    }
    else if (failed == true) {
      print("NOT GEO")
      var new_ref = ref.queryOrdered(byChild: "category")
      if (channelName != "") {new_ref = ref.queryOrdered(byChild: "category").queryEqual(toValue: channelName)}
      new_ref.observe(.value, with: { snapshot in
        self.items = []
        for item in snapshot.children {
          let betItem = BetItem(snapshot: item as! FIRDataSnapshot)
          if (self.friendsOnly == 1) { self.checkFriends(betItem: betItem) }
          else {  self.checkBet(bet: betItem) }
        }
      })
    }
  }
  
  func checkFriends(betItem: BetItem) {
    self.fRef.child(self.profile!.key).observeSingleEvent(of: .value, with: {snapshot in
      if (snapshot.hasChild(betItem.challenger_uid)) {
        self.checkBet(bet: betItem)
      }
      else if(betItem.accepted && betItem.challengee_uid != "" && snapshot.hasChild(betItem.challengee_uid)) {
        self.checkBet(bet: betItem)
      }
    })
  }
  
  func checkBet(bet: BetItem) {
    if (bet.category == self.channelName || self.channelName == "") {
      if (self.betType == self.BET_TYPE_ALL) {self.addVal(betItem: bet) }
      else if(self.betType == self.BET_TYPE_POSED && !bet.accepted) {self.addVal(betItem: bet) }
      else if(self.betType == self.BET_TYPE_ACTIVE && bet.accepted && !bet.completed) {self.addVal(betItem: bet) }
      else if(self.betType == self.BET_TYPE_COMPLETED && bet.completed) {self.addVal(betItem: bet) }
    }
  }
  
  func addVal(betItem: BetItem) {
    //if (items.filter{$0.key == betItem.key}.count > 0) {return}
    items.append(betItem)
    self.items = self.items.sorted{ $0.date_opened > $1.date_opened }
    self.tableView.reloadData()
  }
  
  // MARK: UITableView Delegate methods
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! BetTableViewCell
    let betItem = items[indexPath.row]
    
    cell.betNameLabel.text = betItem.name
    cell.betChallengerLabel.text = betItem.challenger_name
    cell.betAmountLabel.text = String(format: "$%.2f", betItem.amount)
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return false
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let indexPath = tableView.indexPathForSelectedRow!
    selectedBet = items[indexPath.row]
    self.performSegue(withIdentifier: "toIndividualBet", sender: self);
  }
  
  
  // MARK: PREPARE FOR SEGUE
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if (segue.identifier == "toIndividualBet") {
        let vc = segue.destination as! BetViewController
        // Pass the selected object to the new view controller.
        if let indexPath = self.tableView.indexPathForSelectedRow {
          let selectedBet = items[indexPath.row]
          vc.bet = selectedBet
      }
    }
    else if (segue.identifier == "toProfileController") {
      
    }
    else if (segue.identifier == "applyFilter") {
      let vc = segue.destination as! FilterViewController
      vc.fint = self.friendsOnly
      vc.tint = self.betType
      if(self.geo) {vc.gint = 1}
      else {vc.gint = 0}
      vc.rad = radius
      vc.category = self.channelName

    }
  }
}
