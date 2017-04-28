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
  
  @IBOutlet weak var scrollView: UIScrollView!
  // MARK: Outlets
  @IBOutlet weak var textFieldLoginEmail: UITextField!
  @IBOutlet weak var textFieldLoginPassword: UITextField!
  @IBOutlet weak var signupButton: UIButton!
  
  // MARK: Actions
  @IBAction func loginDidTouch(_ sender: AnyObject) {
    FIRAuth.auth()!.signIn(withEmail: textFieldLoginEmail.text!,
                           password: textFieldLoginPassword.text!)
  }

  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.scrollView.isScrollEnabled = false
    
    // some bullshit to allow me to mess with the keybaord
    NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    
    
    signupButton.layer.borderColor = UIColor.white.cgColor
   
    textFieldLoginEmail.borderStyle = .roundedRect
    
    textFieldLoginPassword.borderStyle = .roundedRect;
    

    self.tabBarController?.tabBar.isHidden = true
    
    FIRAuth.auth()!.addStateDidChangeListener() { auth, user in
      if user != nil {
        self.performSegue(withIdentifier: self.loginToList, sender: nil)
      }
    }
    self.navigationController?.navigationBar.topItem?.leftBarButtonItem = nil;
  }
  
  func keyboardWillShow(notification:NSNotification) {
    let userInfo:NSDictionary = notification.userInfo! as NSDictionary
    let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
    let keyboardRectangle = keyboardFrame.cgRectValue
    let keyboardHeight = keyboardRectangle.height
    let height = UIScreen.main.bounds.size.height-keyboardHeight+25
    
    if (UIScreen.main.bounds.size.height < 600)
    {
    self.scrollView.isScrollEnabled = true
    self.scrollView.contentSize=CGSize(width: self.scrollView.contentSize.width, height: height)
    }
    
   
    
  }
  
  func keyboardWillHide(notification:NSNotification) {
    self.scrollView.setContentOffset(CGPoint(x: 0, y:0), animated: true)
    self.scrollView.isScrollEnabled = false
  }
}


  extension LoginViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == textFieldLoginEmail {
      textFieldLoginPassword.becomeFirstResponder()
    }
    if textField == textFieldLoginPassword {
      textField.resignFirstResponder()
self.scrollView.setContentOffset(CGPoint(x: 0, y:0), animated: true)
    }
    
    return true
  }
  
  }

