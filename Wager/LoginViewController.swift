//
//  LoginViewController.swift
//  WagerApp
//
//  Created by Tyler Kaye, Michael Swart, Richard Bush, and William Chance on 4/2/17.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
  
  // MARK: Constants
  let loginToList = "LoginToList"
  let test = 1
  
  // MARK: Outlets
  @IBOutlet weak var textFieldLoginEmail: UITextField!
  @IBOutlet weak var textFieldLoginPassword: UITextField!
  
  // MARK: Actions
  @IBAction func loginDidTouch(_ sender: AnyObject) {
    FIRAuth.auth()!.signIn(withEmail: textFieldLoginEmail.text!,
                           password: textFieldLoginPassword.text!)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tabBarController?.tabBar.isHidden = true
    
    FIRAuth.auth()!.addStateDidChangeListener() { auth, user in
      if user != nil {
        self.performSegue(withIdentifier: self.loginToList, sender: nil)
      }
    }
    self.navigationController?.navigationBar.topItem?.leftBarButtonItem = nil;
  }
}

extension LoginViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == textFieldLoginEmail {
      textFieldLoginPassword.becomeFirstResponder()
    }
    if textField == textFieldLoginPassword {
      textField.resignFirstResponder()
    }
    return true
  }
  
}
