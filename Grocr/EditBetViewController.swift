//
//  EditBetViewController.swift
//  Grocr
//
//  Created by Tyler Kaye on 4/21/17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit
import Firebase

class EditBetViewController: UIViewController {
  @IBOutlet weak var betName: UITextField!
  @IBOutlet weak var betDescription: UITextField!
  @IBOutlet weak var betAmount: UITextField!

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
  
    @IBAction func saveTapped(_ sender: Any) {
      let bRef  = FIRDatabase.database().reference().child("Bets").child((self.bet?.key)!)
      
      if (self.betName.text != "" && self.betName.text != bet?.name) {
        bRef.updateChildValues(["name": self.betName.text ?? ""])
        bet?.name = self.betName.text!
      }
      
      if (self.betDescription.text != "" && self.betDescription.text != bet?.description) {
        bRef.updateChildValues(["description": self.betDescription.text ?? ""])
        bet?.description = self.betDescription.text!
      }
      
      if (self.betAmount.text != "" && self.betAmount.text != String(describing: bet?.amount)){
        if let amount_as_float = Float(self.betAmount.text!) {
          bRef.updateChildValues(["amount": amount_as_float])
        }
      }
      
      dismiss(animated: true, completion: nil)

    }
  

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
