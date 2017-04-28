//
//  NewProfileViewController.swift
//
//  Created by Michael Swart on 4/10/17.
//

import Foundation
import Firebase
import UIKit


class NewProfileViewController: UIViewController {
  
  let ref = FIRDatabase.database().reference(withPath: "Profiles")
  
  @IBOutlet weak var EmailText: UITextField!
  @IBOutlet weak var PasswordText: UITextField!
  @IBOutlet weak var UsernameText: UITextField!
  @IBOutlet weak var birthdayPicker: UIDatePicker!
  @IBOutlet weak var FirstNameText: UITextField!
  @IBOutlet weak var LastNameText: UITextField!
  @IBOutlet weak var VenmoIdText: UITextField!
  @IBOutlet weak var GenderText: UITextField!
  
  
  @IBAction func SignUpPressed(_ sender: Any) {
    /*purge inputs*/
    if (self.EmailText.text! == "") {errorHandler(errorString: "Email cannot be empty"); return}
    if (self.PasswordText.text!.characters.count < 6) {errorHandler(errorString: "Password must be 6 or more characters"); return}
    if (self.FirstNameText.text! == "") {errorHandler(errorString: "First Name cannot be empty"); return}
    if (self.LastNameText.text! == "") {errorHandler(errorString: "Last Name cannot be empty"); return}
    let usernameStr = self.UsernameText.text!
    if (usernameStr == "") {errorHandler(errorString: "Username cannot be empty"); return}
    if (usernameStr.characters.count < 4) {errorHandler(errorString: "Username must be at least 4 characters"); return}
    let pattern = "^([A-Za-z]|[0-9]|_)+$"
    let regex = try! NSRegularExpression(pattern: pattern, options: [])
    if (regex.matches(in: usernameStr, options: [], range: NSRange(location: 0, length: usernameStr.characters.count)).count == 0) {
      errorHandler(errorString: "Username must be only alphanumeric or \"_\"")
      return
    }
    /* Trying to get no duplicate usernames
    var isSeen = false
    /*check to make sure the username has not yet been used*/
    let ref = FIRDatabase.database().reference(withPath: "Profiles")
    ref.observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
      if snapshot.hasChild(usernameStr){
        
      }
    })
    if (isSeen) {errorHandler(errorString: "Username is already in use"); return}*/

    FIRAuth.auth()!.createUser(withEmail: self.EmailText.text!, password: self.PasswordText.text!) {user, error in
      if error == nil {
        FIRAuth.auth()!.signIn(withEmail: self.EmailText.text!, password: self.PasswordText.text!)
        
        let ageNum = self.birthdayPicker.date.timeIntervalSinceReferenceDate
        let newProfRef = self.ref.childByAutoId()
        let profItem = Profile(firstName: self.FirstNameText.text!, lastName: self.LastNameText.text!, email: self.EmailText.text!, pnl: 0, age: Int(ageNum), venmoID: self.VenmoIdText.text!, gender: self.GenderText.text!, userID: (user?.uid)!, username: self.UsernameText.text!)
        newProfRef.setValue(profItem.toAnyObject())
      }
    }
  }
  
  func errorHandler(errorString: String) {
    let alertController = UIAlertController(title: "There was an Error Signing Up", message: errorString, preferredStyle: .alert)
    present(alertController, animated: true, completion: nil)
    let callOK = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(callOK)
  }
}
