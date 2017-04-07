//
//  ProfileViewController.swift
//  Grocr
//
//  Created by William Chance on 4/5/17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
    @IBOutlet weak var UserNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.clipsToBounds = true;
    
    FIRAuth.auth()!.addStateDidChangeListener { auth, user in
      guard let user = user else { return }
      self.user = User(authData: user)
      self.UserNameLabel.text = user.email
    }
    
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
  
  //MARK: Properties
  var user: User!
  
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
}
