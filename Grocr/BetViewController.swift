//
//  BetViewController.swift
//  Grocr
//
//  Created by Tyler Kaye on 4/5/17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit
import Firebase

class BetViewController: UIViewController {
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var challengerLabel: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var takeBetButton: UIButton!
  
  
  var bet: BetItem!
  var betName = "shit"
  var user: User!
  var profile: Profile!

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.user = appDelegate.user
        self.profile = appDelegate.profile
      
        self.nameLabel.text = bet.name
        self.categoryLabel.text = bet.category
        self.challengerLabel.text = bet.challenger_uid
        self.descriptionLabel.text = bet.amount.description
      
      if (user.uid == "") {
        self.takeBetButton.setTitle("Delete Bet?", for: UIControlState.normal)
        self.takeBetButton.backgroundColor = UIColor.red
      }
      else if (!bet.accepted) {
        self.takeBetButton.setTitle("Take Bet", for:UIControlState.normal)
        self.takeBetButton.layer.cornerRadius = 20
      }
      else {
        self.takeBetButton.setTitle("Accepted", for: UIControlState.normal)
        self.takeBetButton.isEnabled = false;
      }
      
        // Do any additional setup after loading the view.
    }

  @IBAction func takeBet(_ sender: Any) {
    if (self.takeBetButton.titleLabel?.text == "Delete Bet?" && 1==1) {
      // DELETE THE BET and NAVIGATE AWAY
    }
    else if (!bet.completed) {
      self.takeBetButton.setTitle("Accepted", for: UIControlState.normal)
      self.takeBetButton.isEnabled = false;
      self.bet.completed = true
      
      let bRef  = FIRDatabase.database().reference().child("Bets").child(bet.key)
      bRef.updateChildValues(["accepted":true])
      bRef.updateChildValues(["challengee_name":user.email])
      bRef.updateChildValues(["challengee_uid":user.uid])
      
    }
  }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
