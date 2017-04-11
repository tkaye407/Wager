//
//  NewProfileViewController.swift
//  Grocr
//
//  Created by Michael Swart on 4/10/17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Foundation
import Firebase
import UIKit


class NewProfileViewController: UIViewController {
  
    let ref = FIRDatabase.database().reference(withPath: "Profiles")
  
    @IBOutlet weak var EmailText: UITextField!
    @IBOutlet weak var PasswordText: UITextField!
    @IBOutlet weak var UsernameText: UITextField!
  
    @IBOutlet weak var FirstNameText: UITextField!
    @IBOutlet weak var LastNameText: UITextField!
    @IBOutlet weak var AgeText: UITextField!
    @IBOutlet weak var VenmoIdText: UITextField!
    @IBOutlet weak var GenderText: UITextField!
    
    @IBAction func SignUpPressed(_ sender: Any) {
      FIRAuth.auth()!.createUser(withEmail: self.EmailText.text!, password: self.PasswordText.text!) {user, error in
        if error == nil {
            FIRAuth.auth()!.signIn(withEmail: self.EmailText.text!, password: self.PasswordText.text!)
          
          let newProfRef = self.ref.childByAutoId()
          let profItem = Profile(firstName: self.FirstNameText.text!, lastName: self.LastNameText.text!, email: self.EmailText.text!, pnl: 0, age: Int((self.AgeText.text!))!, venmoID: self.VenmoIdText.text!, gender: self.GenderText.text!, key: (user?.uid)!, userID: (user?.uid)! /*self.UsernameText.text!*/)
          newProfRef.setValue(profItem.toAnyObject())
        }
        else {
          let alertController = UIAlertController(title: "Unkown Error Logging in", message: "", preferredStyle: .alert)
          let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
          alertController.addAction(defaultAction)
          self.present(alertController, animated: true, completion: nil)
        }
      }
    }
}
