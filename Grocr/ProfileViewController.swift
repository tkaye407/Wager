//
//  ProfileViewController.swift
//  Grocr
//
//  Created by William Chance on 4/5/17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit
import Firebase
import os.log

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var UserNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var venmoIDLabel: UILabel!
    @IBOutlet weak var pnlLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var betsTableView: UITableView!
  
    
    
    //MARK: Properties
    var user: User!
    var profile: Profile?
    let pRef = FIRDatabase.database().reference(withPath: "Profiles")
    let bRef = FIRDatabase.database().reference(withPath: "Bets")
    var bets: [BetItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
      
        // SET THE APP DELEGATE VALUES
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.user = appDelegate.user
        self.profile = appDelegate.profile
      
        // SET THE DELEGATE AND DATA SOURCE TO SELF
        betsTableView.delegate = self
        betsTableView.dataSource = self
      
        // CORNERS ON THE BUTTON
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
        self.profileImageView.clipsToBounds = true;

        // CALCULATE THE TEXT
        calculatePNL()
        self.UserNameLabel.text = profile?.firstName
        self.venmoIDLabel.text = profile?.venmoID
        self.emailLabel.text = profile?.email
        self.genderLabel.text = profile?.gender
      
        // Set Bets
        self.betsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        let new_ref = bRef.queryOrdered(byChild: "challenger_uid").queryEqual(toValue: self.profile?.key)
        new_ref.observe(.value, with: { snapshot in
          var newItems: [BetItem] = []
          for item in snapshot.children {
            let betItem = BetItem(snapshot: item as! FIRDataSnapshot)
            newItems.append(betItem)
          }
          self.bets = newItems
          self.betsTableView.reloadData()
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
        case "editProfile":
            guard let navController = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let profileEditorViewController = navController.topViewController as? ProfileEditorViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            profileEditorViewController.profile = profile
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    
    
    //MARK: Actions
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func unwindEditProfile(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? ProfileEditorViewController, let profile = sourceViewController.profile {
            self.UserNameLabel.text = profile.firstName + " " + profile.lastName
            self.venmoIDLabel.text = profile.venmoID
            self.emailLabel.text = profile.email
            self.genderLabel.text = profile.gender
        }
    }
  
  
  @IBAction func signOutTouched(_ sender: Any) {
    do {
      let ref = FIRDatabase.database().reference()
      ref.child("Users").child(self.user.uid).removeAllObservers()
      try FIRAuth.auth()?.signOut()
      print("FIRUSER - \(FIRAuth.auth()?.currentUser)")
      
      self.navigationController?.performSegue(withIdentifier: "signOutSegue", sender: self.navigationController)
      
    } catch let logOutError {
      
      print("Error Logging User Out - \(logOutError)")
    }
  }
  
  
    //Mark: Private Methods
    private func calculatePNL() {
      let pnl = 0.0
      if pnl >= 0.0 {
        pnlLabel.textColor = UIColor.green
      }
      else {
        pnlLabel.textColor = UIColor.red
        }
    }
  
    // MARK: TABLE VIEW DELEGATE AND DATASOURCE
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return bets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      //let cell = tableView.dequeueReusableCell(withIdentifier: "betCell", for: indexPath) as! BetTableViewCell
      let betItem = bets[indexPath.row]
      let cell:UITableViewCell = self.betsTableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
      
      cell.textLabel?.text =  betItem.name
      return cell
      //cell.betNameLabel.text = betItem.name
      //cell.betChallengerLabel.text = betItem.challenger_name
      //cell.betAmountLabel.text = String(betItem.amount)
      
      return cell
    }
    

}
