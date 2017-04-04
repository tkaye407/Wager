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
  @IBOutlet weak var amountText: UITextField!
  var items: [BetItem] = []
  var user: User!
  @IBOutlet weak var catPicker: UIPickerView!
  var pickerData: [String] = [String]()
  
  @IBAction func CreateNewBetPressed(_ sender: AnyObject) {
    let betItemRef = ref.childByAutoId()
    //let amt:Int? = Int(amountText.text!)
    let cat = pickerData[catPicker.selectedRow(inComponent: 0)]
    let betItem = BetItem(name: reasonText.text!, challenger: user.email ?? "abc", completed: false, amount: amountText.text!, category: cat)
    betItemRef.setValue(betItem.toAnyObject())
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    FIRAuth.auth()!.addStateDidChangeListener { auth, user in
      guard let user = user else { return }
      self.user = User(authData: user)
        
      self.pickerData = ["Baseball", "Basketball", "Football", "Fighting", "School"]
      
      // Connect data:
      self.catPicker.delegate = self
      self.catPicker.dataSource = self
    }
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
