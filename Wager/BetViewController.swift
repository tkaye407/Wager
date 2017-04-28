//
//  BetViewController.swift
//
//  Created by Tyler Kaye on 4/5/17.
//

import UIKit
import Firebase

class BetViewController: UIViewController {
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var takeBetButton: UIButton!
  @IBOutlet weak var challengerButton: UIButton!
  @IBOutlet weak var amountLabel: UILabel!
  @IBOutlet weak var challengeeButton: UIButton!
  @IBOutlet weak var dateOpenedLabel: UILabel!
  @IBOutlet weak var dateClosedLabel: UILabel!
  @IBOutlet weak var InformationLabel: UILabel!
  @IBOutlet weak var editButton: UIButton!
  
  
  var bet: BetItem!
  var betName = "h"
  var user: User!
  var profile: Profile!
  var newProfile: Profile?
  var loserProfile: Profile!
  var challengerProfile: Profile?
  var challengeeProfile: Profile?
  var winnerProfile: Profile!
  
  func reloadBet() {
    let bRef = FIRDatabase.database().reference().child("Bets")
    bRef.child(bet.key).observeSingleEvent(of: .value, with: { (snapshot) in
      // Get user value
      self.bet = BetItem(snapshot: snapshot)
    })
    self.nameLabel.text = self.bet.name
    self.descriptionLabel.text = self.bet.description
    self.amountLabel.text = self.bet.amount.description
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    reloadBet()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    self.user = appDelegate.user
    self.profile = appDelegate.profile
    self.challengerProfile = nil
    self.challengeeProfile = nil
    
    self.setUpProfiles()
    relabelThings()
    //if(bet.challenger_uid == profile.key && bet.date_closed < )
    if !(bet.challenger_uid == profile.key && bet.accepted == false && bet.completed == false && bet.confirmed == false) {
      editButton.isHidden = true
      editButton.isEnabled = false
    }
    print("HI")
  }
  
  func relabelThings() {
    self.takeBetButton.isEnabled = true
    self.takeBetButton.isHidden = false
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "hh:mm a MMM dd, yy"
    let dateOpened = Date(timeIntervalSinceReferenceDate: bet.date_opened)
    
    self.nameLabel.text = bet.name
    self.categoryLabel.text = bet.category
    self.challengerButton.setTitle(bet.challenger_name, for: UIControlState.normal)
    self.descriptionLabel.text = bet.description
    self.amountLabel.text = bet.amount.description
    self.dateOpenedLabel.text = dateFormatter.string(from: dateOpened)
    if (bet.challengee_uid != "") {
      self.challengeeButton.setTitle(bet.challengee_name, for: UIControlState.normal)
      self.challengeeButton.isEnabled = true
    }
    else {
      self.challengeeButton.isEnabled = false
      self.challengeeButton.setTitle("Not Taken", for: UIControlState.normal)
    }
    
    if ((self.profile.key == self.bet.challenger_uid) && bet.accepted == false && bet.confirmed == false && bet.completed == false) {
      self.InformationLabel.text = "You created this bet. Would you like to Delete It?"
      self.takeBetButton.setTitle("Delete Bet?", for: UIControlState.normal)
      self.takeBetButton.backgroundColor = UIColor.red
    }
    else if (!bet.accepted) {
      self.InformationLabel.text = "This bet has not been accepted by anyone yet. Take it before someone else does!"
      self.takeBetButton.setTitle("Take Bet", for:UIControlState.normal)
      self.takeBetButton.layer.cornerRadius = 20
    }
    else if (self.profile.key != self.bet.challenger_uid && self.profile.key != self.bet.challengee_uid) {
      self.InformationLabel.text = "This bet has already been accepted by someone else"
      self.takeBetButton.setTitle("Too Late!", for:UIControlState.normal)
      self.takeBetButton.isEnabled = false
    }
    else if (bet.accepted && !bet.completed) {
      self.InformationLabel.text = "Has the outcome of this bet been decided? If so, complete the bet!"
      self.takeBetButton.setTitle("Complete Bet", for:UIControlState.normal)
    }
    else if (bet.completed && !bet.confirmed){
      if ((bet.winner && (self.profile.key == self.bet.challengee_uid)) || (!bet.winner && (self.profile.key == self.bet.challenger_uid))) {
        if (!bet.paid){
          /*loser is current player and has not yet paid*/
          self.InformationLabel.text = "You lost this bet"
          self.takeBetButton.setTitle("Pay Up", for: UIControlState.normal)
        }
        else if (bet.paid && !bet.confirmed) {
          /*loser is current player and has already paid but the payment has not been confirmed*/
          self.InformationLabel.text = "You have already paid this bet. Waiting for them to confirm your payment"
          self.takeBetButton.setTitle("Waiting for Acceptance", for:UIControlState.normal)
          self.takeBetButton.isEnabled = false
        }
      }
      else if ((bet.winner && (self.profile.key == self.bet.challenger_uid)) || (!bet.winner && (self.profile.key == self.bet.challengee_uid))) {
        if (!bet.paid) {
          /*winner is current player and opponent has not yet paid*/
          self.InformationLabel.text = "Your opponent is in the process of paying this bet"
          self.takeBetButton.setTitle("Waiting for payment", for: UIControlState.normal)
          self.takeBetButton.isEnabled = false
        }
        else if (bet.paid && !bet.confirmed)
        {
          /*winner is current player and has not confirmed the payment yet*/
          self.InformationLabel.text = "Your opponent says that they paid. Confirm that they did"
          self.takeBetButton.setTitle("Confirm Payment", for: UIControlState.normal)
        }
      }
    }
    else if (bet.confirmed){
      /*the bet is completely done*/
      self.InformationLabel.text = "This bet has been completed and paid out"
      self.takeBetButton.setTitle("Bet Complete", for:UIControlState.normal)
      self.takeBetButton.isEnabled = false
    }
    else {
      self.takeBetButton.isEnabled = false;
      self.InformationLabel.text = "No Action"
      self.takeBetButton.setTitle("???", for:UIControlState.normal)
    }
  }
  
  @IBAction func takeBet(_ sender: Any) {
    if (self.takeBetButton.titleLabel?.text == "Delete Bet?") {
      // DELETE THE BET and NAVIGATE AWAY
      self.bet.ref?.removeValue()
      performSegue(withIdentifier: "toProfile", sender: self)
    }
    else if (!bet.accepted) {
      acceptBet()
    }
    else if (bet.accepted && !bet.completed) {
      completeBet()
    }
    else if (bet.completed && !bet.confirmed){
      if ((bet.winner && (self.profile.key == self.bet.challengee_uid)) || (!bet.winner && (self.profile.key == self.bet.challenger_uid)) && !bet.paid){
        /*loser is current player and has not yet paid*/
        loserHasNotYetPaid()
        self.relabelThings()
      }
      else if ((bet.winner && (self.profile.key == self.bet.challenger_uid)) || (!bet.winner && (self.profile.key == self.bet.challengee_uid)) && (bet.paid && !bet.confirmed)) {
        self.confirmPayment()
      }
    }
  }

  func confirmPayment() {
    let alertController = UIAlertController(title: "Confirm Payment", message: "Did your opponent pay up?", preferredStyle: .alert)
    present(alertController, animated: true, completion: nil)
    let callYes = UIAlertAction(title: "Yes", style: .default, handler: {
      action in
      let bRef = FIRDatabase.database().reference().child("Bets").child(self.bet.key)
      bRef.updateChildValues(["confirmed":true])
      self.bet.confirmed = true
      self.relabelThings()
      
      //CHALLENGEE IS THE LOSER
      if self.bet.winner {
        // Get user value
        var curRating = self.challengeeProfile?.rating
        let numRatings = self.challengeeProfile?.numRatings
        let loserPnl = self.challengeeProfile?.pnl
        
        curRating = (curRating!*Float(numRatings!) + 5.0)/Float(numRatings! + 1)
        let loserRef  = FIRDatabase.database().reference().child("Profiles").child(self.bet.challengee_uid)
        loserRef.updateChildValues(["rating":curRating as Any])
        loserRef.updateChildValues(["num_ratings":numRatings!+1])
        loserRef.updateChildValues(["pnl": loserPnl! - self.bet.amount])
        
        let winnerPnl = self.challengerProfile?.pnl
        
        let winnerRef = FIRDatabase.database().reference().child("Profiles").child(self.bet.challenger_uid)
        winnerRef.updateChildValues(["pnl": winnerPnl! + self.bet.amount])
        
      }
        //CHALLENGER IS THE LOSER
      else {
        // Get user value
        var curRating = self.challengerProfile?.rating
        let numRatings = self.challengerProfile?.numRatings
        let loserPnl = self.challengerProfile?.pnl
        
        curRating = (curRating!*Float(numRatings!) + 5.0)/Float(numRatings! + 1)
        let loserRef  = FIRDatabase.database().reference().child("Profiles").child(self.bet.challenger_uid)
        loserRef.updateChildValues(["rating":curRating as Any])
        loserRef.updateChildValues(["num_ratings":numRatings!+1])
        loserRef.updateChildValues(["pnl": loserPnl! - self.bet.amount])
        
        let winnerPnl = self.challengeeProfile?.pnl
        
        let winnerRef = FIRDatabase.database().reference().child("Profiles").child(self.bet.challengee_uid)
        winnerRef.updateChildValues(["pnl": winnerPnl! + self.bet.amount])
      }
    })
    alertController.addAction(callYes)
    let callNo = UIAlertAction(title: "No", style: .default, handler: {
      action in
      var otherProfile = self.challengerProfile
      if (self.profile.key == self.challengerProfile?.key) {otherProfile = self.challengeeProfile}
      var curRating = otherProfile?.rating
      let numRatings = otherProfile?.numRatings
      //The equivalent of giving a zero rating for not paying
      curRating = (curRating!*Float(numRatings!))/Float(numRatings! + 1)
      let ref  = FIRDatabase.database().reference().child("Profiles").child((otherProfile?.key)!)
      ref.updateChildValues(["rating":curRating!])
      ref.updateChildValues(["num_ratings":numRatings!+1])
      otherProfile?.rating = curRating!
      otherProfile?.numRatings = numRatings! + 1
      self.relabelThings()
    })
    alertController.addAction(callNo)
    let callCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
    alertController.addAction(callCancel)
  }
  
  func loserHasNotYetPaid() {
    let bRef  = FIRDatabase.database().reference().child("Bets").child(bet.key)
    
    let alertController = UIAlertController(title: "Pay Now", message: "Choose A Payment Option", preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
    alertController.addAction(cancelAction)
    
    // if the user doesnt have venmo don't give them the option
    
    let callVenmo = UIAlertAction(title: "Venmo", style: .default, handler: {
      action in
      
      bRef.updateChildValues(["paid":true])
      self.bet.paid = true
      
      // Lots of possible errors here, we need
      // both to have a venmo account
      // catch the user saying pay with venmo then never paying
      
      // figure out if you are the challenger or challengee
      
      let pRef = FIRDatabase.database().reference().child("Profiles")
      pRef.child(self.bet.challenger_uid).observeSingleEvent(of: .value, with: { (snapshot) in
        // Get user value
        self.newProfile = Profile(snapshot: snapshot)
        
        // additional error checking needed here in case the other user doesnt have
        let url = URL(string: "venmo://paycharge?txt=pay&amount=\(self.bet.amount)&note=\(self.bet.name)&recipients=\((self.newProfile?.venmoID)!)".replacingOccurrences(of: " ", with: "%20"))
        
        if #available(iOS 10.0, *) {
          UIApplication.shared.open(url!)
        } else {
          UIApplication.shared.openURL(url!)
        }
      })
      { (error) in
        
      }
      
      /*This is where the venmo redirection will go*/
      self.relabelThings()
    })
    
    
    let pRef = FIRDatabase.database().reference().child("Profiles")
    pRef.child(self.bet.challenger_uid).observeSingleEvent(of: .value, with: { (snapshot) in
      // Get user value
      self.newProfile = Profile(snapshot: snapshot)
      
      if (self.profile.venmoID != "") || (self.newProfile?.venmoID != "")
      {
        alertController.addAction(callVenmo)
      }

    })
    
    let callCash = UIAlertAction(title: "Cash", style: .default, handler: {
      action in
      /*figure this out*/
      bRef.updateChildValues(["paid":true])
      self.bet.paid = true
      self.relabelThings()
    })
    alertController.addAction(callCash)
    let callOther = UIAlertAction(title: "Other", style: .default, handler: {
      action in
      /*figure this out*/
      bRef.updateChildValues(["paid":true])
      self.bet.paid = true
      self.relabelThings()
    })
    alertController.addAction(callOther)
    let DontPay = UIAlertAction(title: "Do Not Pay", style: .default, handler: {
      action in
      /*figure this out--- Best to probably label bet.paid as false but bet.confirmed as true*/
      var curRating = self.profile.rating
      let numRatings = self.profile.numRatings
      //The equivalent of giving a zero rating for not paying
      curRating = (curRating*Float(numRatings))/Float(numRatings + 1)
      let ref  = FIRDatabase.database().reference().child("Profiles").child(self.profile.key)
      ref.updateChildValues(["rating":curRating])
      ref.updateChildValues(["num_ratings":numRatings+1])
      self.profile.rating = curRating
      self.profile.numRatings = numRatings + 1
      self.relabelThings()
    })
    alertController.addAction(DontPay)
    self.present(alertController, animated: true, completion: nil)
  }
  
  func completeBet() {
    let bRef = FIRDatabase.database().reference().child("Bets").child(bet.key)
    
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
        bRef.updateChildValues(["completed":true])
        
        self.bet.completed = true
        bRef.updateChildValues(["date_closed": Date().timeIntervalSinceReferenceDate])
        self.relabelThings()
      }
      else if (self.bet.challenger_uid == self.profile.key) {
        self.bet.winner = true
        self.takeBetButton.setTitle("Confirm Payment", for: UIControlState.normal)
        bRef.updateChildValues(["winner":true])
        bRef.updateChildValues(["completed":true])
        
        self.bet.completed = true
        bRef.updateChildValues(["date_closed": Date().timeIntervalSinceReferenceDate])
        self.relabelThings()
      }
    })
    alertController.addAction(callMe)
    let callThem = UIAlertAction(title: "Them", style: .default, handler: {
      action in
      if (self.bet.challengee_uid == self.profile.key) {
        self.bet.winner = true
        self.takeBetButton.setTitle("Pay Up", for: UIControlState.normal)
        bRef.updateChildValues(["winner":true])
        bRef.updateChildValues(["completed":true])
        self.bet.completed = true
        bRef.updateChildValues(["date_closed": Date().timeIntervalSinceReferenceDate])
        self.relabelThings()
      }
      else if (self.bet.challenger_uid == self.profile.key) {
        self.bet.winner = false
        self.takeBetButton.setTitle("Pay Up", for: UIControlState.normal)
        bRef.updateChildValues(["winner":false])
        bRef.updateChildValues(["completed":true])
        self.bet.completed = true
        bRef.updateChildValues(["date_closed": Date().timeIntervalSinceReferenceDate])
        self.relabelThings()
      }
    })
    alertController.addAction(callThem)
    self.present(alertController, animated: true, completion: nil)
    
  }
  
  func acceptBet() {
    let bRef = FIRDatabase.database().reference().child("Bets").child(bet.key)
    self.takeBetButton.setTitle("Complete Bet", for: UIControlState.normal)
    self.bet.accepted = true
    self.bet.challengee_uid = self.profile.key
    self.bet.challengee_name = self.profile.firstName + " " + self.profile.lastName
    
    
    bRef.updateChildValues(["accepted":true])
    bRef.updateChildValues(["challengee_name": self.profile.firstName + " " + self.profile.lastName])
    bRef.updateChildValues(["challengee_uid":self.profile.key])
    
    self.challengeeProfile = self.profile
    
    self.relabelThings()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func challengeeClicked(_ sender: Any) {
    if (self.challengeeProfile == nil) {errorHandler(errorString: "Profile not yet loaded. Try again in a couple seconds!")}
    else {performSegue(withIdentifier: "betToChallengee", sender: self)}
  }
  
  @IBAction func challengerClicked(_ sender: Any) {
    if (self.challengerProfile == nil) {errorHandler(errorString: "Profile not yet loaded. Try again in a couple seconds!")}
    else {performSegue(withIdentifier: "betToChallenger", sender: self)}
    
  }
  
  @IBAction func unwindEditProfile(sender: UIStoryboardSegue) {
    if let sourceViewController = sender.source as? EditBetViewController, let bet = sourceViewController.bet {
      self.bet = bet
    }
  }
  
  func setUpProfiles() {
    let pRef = FIRDatabase.database().reference().child("Profiles")
    pRef.child(bet.challenger_uid).observeSingleEvent(of: .value, with: { (snapshot) in
      self.challengerProfile = Profile(snapshot: snapshot)
    })
    if(bet.accepted) {
      pRef.child(bet.challengee_uid).observeSingleEvent(of: .value, with: { (snapshot) in
        self.challengeeProfile = Profile(snapshot: snapshot)
      })
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    if (segue.identifier == "betToChallenger") {
      let vc = segue.destination as! ProfileViewController
      vc.profile = self.challengerProfile
    }
    if (segue.identifier == "editBet") {
      let nav = segue.destination as! UINavigationController
      let vc = nav.topViewController as! EditBetViewController
      vc.bet = self.bet
    }
    if (segue.identifier == "toProfile") {
      let vc = segue.destination as! ProfileViewController
      vc.navigationItem.hidesBackButton = true;
    }
    if (segue.identifier == "betToChallengee") {
      let vc = segue.destination as! ProfileViewController
      vc.profile = self.challengeeProfile
    }
    
  }
  
  func errorHandler(errorString: String) {
    let alertController = UIAlertController(title: "There Was an Error Loading the profile", message: errorString, preferredStyle: .alert)
    present(alertController, animated: true, completion: nil)
    let callOK = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(callOK)
  }
  
}
