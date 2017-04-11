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

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var UserNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var venmoIDLabel: UILabel!
    @IBOutlet weak var pnlLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var signOutButton: UIButton!
    
    
    //MARK: Properties
    var user: User!
    var profile: Profile?
    let pRef = FIRDatabase.database().reference(withPath: "Profiles")

  
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
        self.profileImageView.clipsToBounds = true;
        FIRAuth.auth()!.addStateDidChangeListener { auth, user in
            guard let user = user else { return }
            self.user = User(authData: user)
            if user != nil {
              self.pRef.queryOrdered(byChild: "userID").queryEqual(toValue: "-KhOzyN7afL73GdNyZ6B").observe(.value, with:{ snapshot in
                for item in snapshot.children {
                  self.profile = Profile(snapshot: item as! FIRDataSnapshot)
                }
              })
          }
      }
        calculatePNL()
      
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
}
