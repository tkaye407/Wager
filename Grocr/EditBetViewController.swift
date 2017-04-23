//
//  EditBetViewController.swift
//  Grocr
//
//  Created by Tyler Kaye on 4/21/17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit
import Firebase
import os.log

class EditBetViewController: UIViewController {
  @IBOutlet weak var betName: UITextField!
  @IBOutlet weak var betDescription: UITextField!
  @IBOutlet weak var betAmount: UITextField!
  @IBOutlet weak var saveButton: UIBarButtonItem!

  var profile: Profile!
  var bet: BetItem?
  
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.profile = appDelegate.profile
      
        self.betName.text = bet?.name
        self.betDescription.text = bet?.description
        if let amt = bet?.amount {
          self.betAmount.text = String(amt)
        }
        self.betAmount.keyboardType = UIKeyboardType.numberPad
    
      

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
      dismiss(animated: true, completion: nil)
    }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    
    guard let button = sender as? UIBarButtonItem, button === saveButton else {
      os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
      return
    }
    
    let bRef  = FIRDatabase.database().reference().child("Bets").child((self.bet?.key)!)
    
    if (self.betName.text != "" && self.betName.text != bet?.name) {
      bRef.updateChildValues(["name": self.betName.text ?? ""])
      bet?.name = self.betName.text!
    }
    
    if (self.betDescription.text != "" && self.betDescription.text != bet?.description) {
      bRef.updateChildValues(["description": self.betDescription.text ?? ""])
      bet?.description = self.betDescription.text!
    }
    
    if (self.betAmount.text != "" && Float(self.betAmount.text!) != bet?.amount){
      if let amount_as_float = Float(self.betAmount.text!) {
        bRef.updateChildValues(["amount": amount_as_float])
        bet?.amount = amount_as_float
      }
    }
  }


}
