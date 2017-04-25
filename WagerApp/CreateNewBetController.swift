//
//  CreateNewBetContoller.swift
//  WagerApp
//
//  Created by Tyler Kaye, Michael Swart, Richard Bush, and William Chance on 4/2/17.
//

import UIKit
import Firebase

class CreateNewBetController: UIViewController,  UIPickerViewDelegate, UIPickerViewDataSource {

  @IBOutlet weak var reasonText: UITextField!
  let ref = FIRDatabase.database().reference(withPath: "Bets")
  let cRef = FIRDatabase.database().reference(withPath: "Categories")
  @IBOutlet weak var amountText: UITextField!
  var user: User!
  var profile: Profile!
  @IBOutlet weak var catPicker: UIPickerView!
  var pickerData: [String] = [String]()
  let MAX_BET = Float(500.0)
  @IBOutlet weak var descriptionLabel: UITextField!
  
  
  @IBAction func CreateNewBetPressed(_ sender: AnyObject) {
    /*purge inputs*/
    let amount_as_float = Float(amountText.text!)
    if (reasonText.text! == "") {errorHandler(errorString: "Bet reason cannot be empty"); return}
    if (reasonText.text!.characters.count > 50) {errorHandler(errorString: "Bet reason too long (>50 characters). Use the bet description for the less important information"); return}
    if (amount_as_float == nil) {errorHandler(errorString: "Amount cannot be blank or non-numeric"); return}
    if (amount_as_float! > MAX_BET) {errorHandler(errorString: "Amount cannot be larger than $" + String(MAX_BET)); return}
    
    /*will only make it here if all tests pass*/
    /*Firebase takes care of [",/;{}] and other weird characters that could mess with the database*/
    
    let betItemRef = ref.childByAutoId()
    //let amt:Int? = Int(amountText.text!)
    let cat = pickerData[catPicker.selectedRow(inComponent: 0)]
    
    let betItem = BetItem(name: reasonText.text!, description: self.descriptionLabel.text!, challenger_uid: self.profile.key, challenger_name: self.profile.firstName + " " + self.profile.lastName, date_opened: Date().timeIntervalSinceReferenceDate, date_closed: Date().timeIntervalSinceReferenceDate, category: cat, amount: amount_as_float!)
      betItemRef.setValue(betItem.toAnyObject())
  }

  func errorHandler(errorString: String) {
    let alertController = UIAlertController(title: "There was an Error creating the bet", message: errorString, preferredStyle: .alert)
    present(alertController, animated: true, completion: nil)
    let callOK = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(callOK)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    self.user = appDelegate.user
    self.profile = appDelegate.profile
    //self.pickerData = ["Baseball", "Basketball", "Football", "Fighting", "School"]
    
    // Connect data:
    self.catPicker.delegate = self
    self.catPicker.dataSource = self
    
    cRef.observe(.value, with: { snapshot in
      for item in snapshot.children {
        let currCat = item as! FIRDataSnapshot
        let snapshotValue = currCat.value as! String
        self.pickerData.append(snapshotValue)
      }
      self.catPicker.reloadAllComponents();
    })
    
    amountText.keyboardType = UIKeyboardType.numberPad

  }
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  // The number of rows of data
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
  {
    return pickerData.count
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return pickerData[row]
  }


}
