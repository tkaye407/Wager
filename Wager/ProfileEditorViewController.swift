//
//  ProfileEditorViewController.swift
//
//  Created by William Chance on 4/7/17.
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
    @IBOutlet weak var usernameTextField: UITextField!
  
  
  var profile: Profile!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    self.profile = appDelegate.profile
    
    firstNameTextField.text = profile?.firstName
    lastNameTextField.text = profile?.lastName
    emailTextField.text = profile?.email
    ageTextField.keyboardType = UIKeyboardType.decimalPad
    ageTextField.text = String(profile!.age)
    venmoIDTextField.text = profile?.venmoID
    genderTextField.text = profile?.gender
    usernameTextField.text = profile?.username
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
      let ref  = FIRDatabase.database().reference().child("Profiles").child(self.profile.key)

      
      let firstName = firstNameTextField.text ?? ""
      if (firstName != profile?.lastName && firstName != "") {
        ref.updateChildValues(["firstName":firstName])
        profile.firstName = firstName
      }
      
      let lastName = lastNameTextField.text ?? "" //replace this with profile.lastName
      if (lastName != profile?.lastName && lastName != "")  {
        ref.updateChildValues(["lastName":lastName])
        profile.lastName = lastName
      }
      
      let email = emailTextField.text ?? "" //replace this with profile.lastName
      if (email != profile?.email && email != "")  {
        ref.updateChildValues(["email":email])
        profile.email = email
      }
      
      let venmoID = venmoIDTextField.text ?? "" //replace this with profile.lastName
      if (venmoID != profile?.venmoID && venmoID != "")  {
        ref.updateChildValues(["venmoID":venmoID])
        profile.venmoID = venmoID
      }
      
      let gender = genderTextField.text ?? "" //replace this with profile.lastName
      if (gender != profile?.gender && gender != "")  {
        ref.updateChildValues(["gender":gender])
        profile.gender = gender
      }
      
      let age = Int(ageTextField.text!) //replace this with profile.lastName
      if (age != nil && age != profile?.age)  {
        ref.updateChildValues(["age":age ?? 0])
        profile.age = age!
      }
    let username = usernameTextField.text ?? ""
    if (username != "" && username != profile?.username)  {
        ref.updateChildValues(["username":username])
        profile.username = username
    }
      
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      appDelegate.profile = self.profile
    }
    
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
  
  
}
