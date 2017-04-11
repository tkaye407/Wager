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
      
      if (self.profile.key == self.bet.challenger_uid) {
        self.takeBetButton.setTitle("Delete Bet?", for: UIControlState.normal)
        self.takeBetButton.backgroundColor = UIColor.red
      }
      else if (!bet.accepted) {
        self.takeBetButton.setTitle("Take Bet", for:UIControlState.normal)
        self.takeBetButton.layer.cornerRadius = 20
      }
      else if (self.profile.key != self.bet.challenger_uid && self.profile.key != self.bet.challengee_uid) {
        self.takeBetButton.setTitle("Too Late (Bet Already Accepted)", for:UIControlState.normal)
        self.takeBetButton.isEnabled = false
      }
      else if (bet.accepted && !bet.completed) {
        self.takeBetButton.setTitle("Complete Bet", for:UIControlState.normal)
      }
      else if (bet.completed){
        if (((bet.winner && self.profile.key == self.bet.challengee_uid) || (!bet.winner && self.profile.key == self.bet.challenger_uid)) && !bet.paid){
          self.takeBetButton.setTitle("Pay Up", for: UIControlState.normal)
        }
        else if (bet.winner && self.profile.key == self.bet.challengee_uid || !bet.winner && self.profile.key == self.bet.challenger_uid) {
          self.takeBetButton.setTitle("Waiting for Acceptance", for:UIControlState.normal)
          self.takeBetButton.isEnabled = false
        }
        else if (bet.paid) {
          self.takeBetButton.setTitle("Confirm Payment", for: UIControlState.normal)
        }
        else if bet.completed{self.takeBetButton.setTitle("Bet Complete", for:UIControlState.normal)
          self.takeBetButton.isEnabled = false}
        else {self.takeBetButton.setTitle("Unkown", for:UIControlState.normal)
          self.takeBetButton.isEnabled = false
        }
      }
      else {
        self.takeBetButton.isEnabled = false;
      }
      
        // Do any additional setup after loading the view.
    }

  @IBAction func takeBet(_ sender: Any) {
    if (self.takeBetButton.titleLabel?.text == "Delete Bet?") {
      // DELETE THE BET and NAVIGATE AWAY
    }
    else if (!bet.accepted) {
      acceptBet()
    }
    else if (bet.accepted && !bet.completed) {
      completeBet()
    }
    else if (bet.completed) {
      //loser
      if ((bet.winner && self.profile.key == self.bet.challengee_uid || !bet.winner && self.profile.key == self.bet.challenger_uid) && !bet.paid){
        loserHasNotYetPaid()
        self.takeBetButton.setTitle("Waiting for Acceptance", for: UIControlState.normal)
        self.takeBetButton.isEnabled = false
      }
      else if (bet.winner && self.profile.key == self.bet.challengee_uid || !bet.winner && self.profile.key == self.bet.challenger_uid){
        /*Loser has alread paid*/
        self.takeBetButton.setTitle("Waiting for Acceptance", for:UIControlState.normal)
        self.takeBetButton.isEnabled = false
      }
      else if (bet.paid) {
         let bRef = FIRDatabase.database().reference().child("Bets").child(bet.key)
         bRef.updateChildValues(["confirmed":true])
         bet.confirmed = true
        self.takeBetButton.setTitle("Bet Complete", for:UIControlState.normal)
        self.takeBetButton.isEnabled = false
      }
    }
  }
  
  func loserHasNotYetPaid() {
    let bRef  = FIRDatabase.database().reference().child("Bets").child(self.bet.key)
    bRef.updateChildValues(["paid":true])
    self.bet.paid = true
    let alertController = UIAlertController(title: "Pay Now", message: "Choose A Payment Option", preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {action in bRef.updateChildValues(["paid":false]); self.bet.paid = false})
    alertController.addAction(cancelAction)
    let callVenmo = UIAlertAction(title: "Venmo", style: .default, handler: {
      action in
      /*This is where the venmo redirection will go*/
    })
    alertController.addAction(callVenmo)
    let callCash = UIAlertAction(title: "Cash", style: .default, handler: {
      action in
      /*figure this out*/
    })
    alertController.addAction(callCash)
    let callOther = UIAlertAction(title: "Other", style: .default, handler: {
      action in
      /*figure this out*/
    })
    alertController.addAction(callOther)
    let DontPay = UIAlertAction(title: "Do Not Pay", style: .default, handler: {
      action in
      /*figure this out*/
    })
    alertController.addAction(DontPay)
    self.present(alertController, animated: true, completion: nil)
  }
  
  func completeBet() {
    let bRef = FIRDatabase.database().reference().child("Bets").child(bet.key)
    self.bet.completed = true
    
    let alertController = UIAlertController(title: "Who Won?", message: "Choose One", preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
      action in
      return
    })
    alertController.addAction(cancelAction)
    let callMe = UIAlertAction(title: "Me", style: .default, handler: {
      action in
      if (self.bet.challengee_uid == self.profile.key) {
        self.bet.winner = false
        self.takeBetButton.setTitle("Confirm Payment", for: UIControlState.normal)
        bRef.updateChildValues(["winner":false])
      }
      else if (self.bet.challenger_uid == self.profile.key) {
        self.bet.winner = true
        self.takeBetButton.setTitle("Confirm Payment", for: UIControlState.normal)
        bRef.updateChildValues(["winner":true])
      }
    })
    alertController.addAction(callMe)
    let callThem = UIAlertAction(title: "Them", style: .default, handler: {
      action in
      if (self.bet.challengee_uid == self.profile.key) {
        self.bet.winner = true
        self.takeBetButton.setTitle("Pay Up", for: UIControlState.normal)
        bRef.updateChildValues(["winner":true])
      }
      else if (self.bet.challenger_uid == self.profile.key) {
        self.bet.winner = false
        self.takeBetButton.setTitle("Pay Up", for: UIControlState.normal)
        bRef.updateChildValues(["winner":false])
      }
    })
    alertController.addAction(callThem)
    self.present(alertController, animated: true, completion: nil)
    
    bRef.updateChildValues(["completed":true])
    bRef.updateChildValues(["date_closed": Date().timeIntervalSinceReferenceDate])
    
  }
  
  func acceptBet() {
    let bRef = FIRDatabase.database().reference().child("Bets").child(bet.key)
    self.takeBetButton.setTitle("Complete Bet", for: UIControlState.normal)
    self.bet.accepted = true
    
    bRef.updateChildValues(["accepted":true])
    bRef.updateChildValues(["challengee_name": self.profile.firstName + " " + self.profile.lastName])
    bRef.updateChildValues(["challengee_uid":self.profile.key])
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
