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
  
    //Mark: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        // Update the database with new profile information
        /* let firstName = firstNameTextField.text ?? ""
        let lastName = lastNameTextField.text ?? "" //replace this with profile.lastName
        let email = emailTextField.text ?? ""
        let age:Int? = Int(ageTextField.text!)
        let venmoID = venmoIDTextField.text ?? ""
        let gender = genderTextField.text ?? ""
        let key = "example"
        let userID = "ex"
        let pnl = Float(0.0)*/
      
      profile = Profile(firstName: firstNameTextField.text ?? (profile?.firstName)!, lastName: lastNameTextField.text ?? (profile?.lastName)!)
    }
    
}
