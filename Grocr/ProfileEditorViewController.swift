//
//  ProfileEditorViewController.swift
//  Grocr
//
//  Created by William Chance on 4/7/17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//
import UIKit
import Firebase
import os.log

class ProfileEditorViewController: UIViewController {
  
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var venmoIDTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
  
  
  var profile: Profile?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    firstNameTextField.text = profile?.firstName
    lastNameTextField.text = profile?.lastName
    emailTextField.text = profile?.email
    ageTextField.keyboardType = UIKeyboardType.decimalPad
    ageTextField.text = "\(profile?.age)"
    venmoIDTextField.text = profile?.venmoID
    genderTextField.text = profile?.gender
  }
  
    //Mark: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }

      // Update the database with new profile information
      //let ref  = FIRDatabase.database().reference().child("Profiles").child((profile?.key)!)
      let ref  = FIRDatabase.database().reference().child("Profiles").child("-KhOzyN7afL73GdNyZ6B")

      
      let firstName = firstNameTextField.text ?? ""
      if (firstName != profile?.lastName && firstName != "") {
        ref.updateChildValues(["firstName":firstName])
      }
      
      let lastName = lastNameTextField.text ?? "" //replace this with profile.lastName
      if (lastName != profile?.lastName && lastName != "")  {
        ref.updateChildValues(["lastName":lastName])
      }
      
      let email = emailTextField.text ?? "" //replace this with profile.lastName
      if (email != profile?.email && email != "")  {
        ref.updateChildValues(["email":email])
      }
      
      let venmoID = profile?.venmoID ?? "" //replace this with profile.lastName
      if (venmoID != profile?.venmoID && venmoID != "")  {
        ref.updateChildValues(["venmoID":venmoID])
      }
      
      let gender = genderTextField.text ?? "" //replace this with profile.lastName
      if (gender != profile?.gender && gender != "")  {
        ref.updateChildValues(["gender":gender])
      }
      
      let age = Int(ageTextField.text!) //replace this with profile.lastName
      if (age != nil && age != profile?.age)  {
        ref.updateChildValues(["age":age ?? 0])
      }
    }
    
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
  
  
}
