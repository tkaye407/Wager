//
//  ProfileViewController.swift
//
//  Created by William Chance on 4/5/17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit
import Firebase
import os.log

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var AddFriendButton: UIButton!
    @IBOutlet weak var UserNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var venmoIDLabel: UILabel!
    @IBOutlet weak var pnlLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var betsTableView: UITableView!
    @IBOutlet weak var ratingView: RatingControl!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var completedController: UISegmentedControl!
    @IBOutlet weak var signUpButton: UINavigationItem!

    //MARK: Properties
    var user: User!
    var profile: Profile?
    let pRef = FIRDatabase.database().reference(withPath: "Profiles")
    let bRef = FIRDatabase.database().reference(withPath: "Bets")
    let fRef = FIRDatabase.database().reference(withPath: "Friends")
    var bets: [BetItem] = []
    var items: [BetItem] = []
    var selectedBet: BetItem?
    var challengerPicked: Bool = true
    var completedPicked: Bool = false
  
  
  func setProfile() {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    if self.profile?.userID != appDelegate.profile?.userID {
      self.navigationItem.rightBarButtonItem?.isEnabled = false
      self.navigationItem.rightBarButtonItem?.tintColor = UIColor.clear
      self.navigationItem.leftBarButtonItem?.isEnabled = false
      self.navigationItem.leftBarButtonItem?.tintColor = UIColor.clear

    }
    self.UserNameLabel.text = profile?.username
    self.venmoIDLabel.text = profile?.venmoID
    self.emailLabel.text = profile?.email
    
    self.genderLabel.text = (profile?.gender)! + " - " + getAge()
    self.ratingView.rating = Int(round(profile!.rating))
    self.ratingLabel.text = String(profile!.rating)
    calculatePNL()
    self.betsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    /*image load*/
    var finalImage: UIImage? = nil
    let imageRef = FIRStorage.storage().reference(withPath: (self.profile?.userID)!)
    imageRef.data(withMaxSize: 1 * 10240 * 10240) { data, error in
      if error != nil {
          print(error)
      }
      else{
          finalImage = UIImage(data: data!)!
          self.profileImageView.image = finalImage
      }
    }
    
    
    let new_ref = bRef.queryOrdered(byChild: "challenger_uid").queryEqual(toValue: self.profile?.key)
    new_ref.observe(.value, with: { snapshot in
      var newItems: [BetItem] = []
      for item in snapshot.children {
        let betItem = BetItem(snapshot: item as! FIRDataSnapshot)
        if (betItem.completed) {
          newItems.append(betItem)
        }
      }
      self.bets = newItems
      self.betsTableView.reloadData()
    })

  }
  
  func getAge() -> String {
    let ageDate = Date(timeIntervalSinceReferenceDate: TimeInterval(profile!.age))
    let calendar = Calendar.current
    
    let birthYear = calendar.component(.year, from: ageDate)
    let birthMonth = calendar.component(.month, from: ageDate)
    let birthDay = calendar.component(.day, from: ageDate)
    let currentYear = calendar.component(.year, from: Date())
    let currentMonth = calendar.component(.month, from: Date())
    let currentDay = calendar.component(.day, from: Date())
    
    /*print("BY: " + String(birthYear) + "\t" + "CY: " + String(currentYear))
    print("BM: " + String(birthMonth) + "\t" + "CY: " + String(currentYear))
    print(birthDay)*/
    
    var ageNum = currentYear - birthYear
    if (currentMonth < birthMonth) {ageNum-=1}
    else if (currentMonth == birthMonth && currentDay < birthDay) {ageNum-=1}
    
    return String(ageNum)
  }
  
//  override func viewWillAppear(_ animated: Bool) {
//    super.viewWillAppear(animated)
//    calculatePNL()
//    debugPrint("Profile: " + (self.profile?.email)!)
//  }
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
        // SET THE APP DELEGATE VALUES
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if self.profile == nil && self.user == nil {
          self.user = appDelegate.user
          self.profile = appDelegate.profile
        }
      
      isFriend()

        // SET THE DELEGATE AND DATA SOURCE TO SELF
        betsTableView.delegate = self
        betsTableView.dataSource = self
        self.completedController.selectedSegmentIndex = 1
      
        // CORNERS ON THE PROFILE IMAGE
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
        self.profileImageView.clipsToBounds = true;

        // CALCULATE THE TEXT
        setProfile()
        calculatePNL()
  }
  
  func isFriend() {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    self.fRef.child((appDelegate.profile?.key)!).observeSingleEvent(of: .value, with: {snapshot in
      if snapshot.hasChild((self.profile?.key)!) {
        self.AddFriendButton.isEnabled = false
        self.AddFriendButton.setTitle("Your Friend", for: .normal)
      }
    })
  }
  
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
      // The info dictionary may contain multiple representations of the image. You want to use the original.
      guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
          fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
      }
        
      // Set photoImageView to display the selected image.
      profileImageView.image = selectedImage
      
      
      let storageRef = FIRStorage.storage().reference().child((self.profile?.userID)!)
      let finalImage = UIImagePNGRepresentation(selectedImage)
      storageRef.put(finalImage!, metadata: nil, completion: {(metadata, error) in
        if(error != nil) {print("error"); return}
        else{ print("metadata")}
      })
      // Dismiss the picker.
      dismiss(animated: true, completion: nil)
    }
    
    //MARK: Navigation
    // This method lets you configure a view controller before it's presented.
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        if isPresentingInAddMealMode {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The MealViewController is not inside a navigation controller.")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        case "signOut":
          do {
            let ref = FIRDatabase.database().reference()
            ref.child("Users").child(self.user.uid).removeAllObservers()
            try FIRAuth.auth()?.signOut()
            print("FIRUSER - \(FIRAuth.auth()?.currentUser)")
            
           // let vc = segue.destination as! LoginViewController
         //   vc.navigationItem.hidesBackButton = true
          //  vc.tabBarController?.tabBar.isHidden = true
         
          } catch let logOutError {
            
            print("Error Logging User Out - \(logOutError)")
          }
        case "editProfile":
            guard let navController = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let profileEditorViewController = navController.topViewController as? ProfileEditorViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            profileEditorViewController.profile = profile
        case "toIndividualBet":
            let vc = segue.destination as! BetViewController
            // Pass the selected object to the new view controller.
            if let indexPath = betsTableView.indexPathForSelectedRow {
              let selectedBet = bets[indexPath.row]
              vc.bet = selectedBet
            }
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }

    //MARK: Actions
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
      
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      
      if self.profile?.userID == appDelegate.profile?.userID {
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
      }
    }
    
    @IBAction func unwindEditProfile(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? ProfileEditorViewController, let profile = sourceViewController.profile {
            self.profile = profile
            setProfile()
        }
      setProfile()
    }
  
  
  @IBAction func signOutTouched(_ sender: Any) {
    do {
      let ref = FIRDatabase.database().reference()
      ref.child("Users").child(self.user.uid).removeAllObservers()
      try FIRAuth.auth()?.signOut()
      print("FIRUSER - \(FIRAuth.auth()?.currentUser)")
      
        } catch let logOutError {
      
      print("Error Logging User Out - \(logOutError)")
    }
  }
    
  
  
    //Mark: Private Methods
    private func calculatePNL() {
      let pnl = Float((self.profile?.pnl)!)
      
      if pnl >= 0.0 {
        pnlLabel.textColor = UIColor.green
        pnlLabel.text = String(format:"$%.2f",pnl)
      }
      else {
        pnlLabel.textColor = UIColor.red
        pnlLabel.text = String(format:"$%.2f",pnl)
        }
    }
  
  
    // MARK: TABLE VIEW DELEGATE AND DATASOURCE
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return bets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let betItem = bets[indexPath.row]
      let cell = self.betsTableView.dequeueReusableCell(withIdentifier: "ProfileBetTableViewCell") as! ProfileBetTableViewCell
      
      cell.betNameLabel.text = betItem.name
      cell.challengerLabel.text = betItem.challenger_name
      cell.amountLabel.text = String(format: "$%.2f", betItem.amount)

      
      return cell
      
    }
    @IBAction func sayHi()
    {
      print("hi")
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
      return true
    }
  
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
      let indexPath = tableView.indexPathForSelectedRow!
      selectedBet = bets[indexPath.row]
      self.performSegue(withIdentifier: "toIndividualBet", sender: self);
    }
  
  
  // MARK: Segment Control Methods
  @IBAction func completedChanged(_ sender: UISegmentedControl) {
    switch completedController.selectedSegmentIndex
    {
    case 0:
      completedPicked = false
      var child: String = ""
      if (self.challengerPicked) {
        child = "challenger_uid"
      }
      else {
        child = "challengee_uid"
      }
      let new_ref = bRef.queryOrdered(byChild: child).queryEqual(toValue: self.profile?.key)
      new_ref.observe(.value, with: { snapshot in
        var newItems: [BetItem] = []
        for item in snapshot.children {
          let betItem = BetItem(snapshot: item as! FIRDataSnapshot)
          if(betItem.confirmed == false) {
            newItems.append(betItem)
          }
        }
        self.bets = newItems
        self.betsTableView.reloadData()
      })
    case 1:
      completedPicked = true
      var child: String = ""
      if (self.challengerPicked) {
        child = "challenger_uid"
      }
      else {
        child = "challengee_uid"
      }
      let new_ref = bRef.queryOrdered(byChild: child).queryEqual(toValue: self.profile?.key)
      new_ref.observe(.value, with: { snapshot in
        var newItems: [BetItem] = []
        for item in snapshot.children {
          let betItem = BetItem(snapshot: item as! FIRDataSnapshot)
          if(betItem.confirmed == true) {
            newItems.append(betItem)
          }
        }
        self.bets = newItems
        self.betsTableView.reloadData()
      })
    default:
      break
    }
  }
  
    @IBAction func AddFriendButtonTouched(_ sender: Any) {
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let profRef = fRef.child((appDelegate.profile?.key)!).child((self.profile?.key)!)
      profRef.setValue(self.profile?.username)
  }

}
