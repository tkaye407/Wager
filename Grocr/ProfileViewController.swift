//
//  ProfileViewController.swift
//  Grocr
//
//  Created by William Chance on 4/5/17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
  
  
  @IBOutlet weak var UserNameLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    FIRAuth.auth()!.addStateDidChangeListener { auth, user in
      guard let user = user else { return }
      self.user = User(authData: user)
      self.UserNameLabel.text = user.email
    }
    
    
  }
  
  
  //MARK: Properties
  var user: User!
}
