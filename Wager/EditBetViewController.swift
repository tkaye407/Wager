//
//  EditBetViewController.swift
//
//  Created by Tyler Kaye on 4/21/17.
//

import UIKit
import Firebase
import os.log

class EditBetViewController: UIViewController {
  @IBOutlet weak var betName: UITextField!
  @IBOutlet weak var betDescription: UITextField!
  @IBOutlet weak var betAmount: UITextField!
  @IBOutlet weak var saveButton: UIBarButtonItem!
  
  let MAX_BET = Float(500.0)

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
  
  override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
    /*purge inputs*/
    let amount_as_float = Float(betAmount.text!)
    if (betName.text! == "") {errorHandler(errorString: "Bet reason cannot be empty"); return false}
    if (betName.text!.characters.count > 50) {errorHandler(errorString: "Bet reason too long (>50 characters). Use the bet description for the less important information"); return false}
    if (amount_as_float == nil) {errorHandler(errorString: "Amount cannot be blank or non-numeric"); return false}
    if (amount_as_float! > MAX_BET) {
      errorHandler(errorString: "Amount cannot be larger than $" + String(MAX_BET));
      return false }
    return true
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    
    guard let button = sender as? UIBarButtonItem, button === saveButton else {
      os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
      return
    }
    
    let bRef  = FIRDatabase.database().reference().child("Bets").child((self.bet?.key)!)
    if (self.betName.text != bet?.name) {
      bRef.updateChildValues(["name": self.betName.text ?? ""])
      bet?.name = self.betName.text!
    }
    if (self.betDescription.text != bet?.description) {
      bRef.updateChildValues(["description": self.betDescription.text ?? ""])
      bet?.description = self.betDescription.text!
    }
    let amount_as_float = Float(betAmount.text!)
    if (amount_as_float != bet?.amount){
      bRef.updateChildValues(["amount": amount_as_float!])
      bet?.amount = amount_as_float!
    }
  }
  
  func errorHandler(errorString: String) {
    let alertController = UIAlertController(title: "There was an Error editing the bet", message: errorString, preferredStyle: .alert)
    present(alertController, animated: true, completion: nil)
    let callOK = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(callOK)
  }


}
