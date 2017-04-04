//
//  CreateNewBetContoller.swift
//  WagerApp
//
//  Created by Tyler Kaye, Michael Swart, Richard Bush, and William Chance on 4/2/17.
//

import UIKit
import Firebase

class CreateNewBetController: UIViewController {
  @IBOutlet weak var reasonText: UITextField!
  let ref = FIRDatabase.database().reference(withPath: "Bets")
  @IBOutlet weak var amountText: UITextField!
  var items: [BetItem] = []
  var user: User!
  
  @IBAction func CreateNewBetPressed(_ sender: AnyObject) {
    let betItemRef = ref.childByAutoId()
    //let amt:Int? = Int(amountText.text!)
    let betItem = BetItem(name: reasonText.text!, challenger: user.email ?? "abc", completed: false, amount: amountText.text!)
    betItemRef.setValue(betItem.toAnyObject())
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    FIRAuth.auth()!.addStateDidChangeListener { auth, user in
      guard let user = user else { return }
      self.user = User(authData: user)
    }
  }

}
