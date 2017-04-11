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
  @IBOutlet weak var catPicker: UIPickerView!
  var pickerData: [String] = [String]()

  
  @IBAction func CreateNewBetPressed(_ sender: AnyObject) {
    let betItemRef = ref.childByAutoId()
    //let amt:Int? = Int(amountText.text!)
    let cat = pickerData[catPicker.selectedRow(inComponent: 0)]
    let betItem = BetItem(name: reasonText.text!, description: "none yet", challenger_uid: user.uid , challenger_name: user.email, date_opened: 1/*NSDate()*/, date_closed: 1/*NSDate()*/, category: cat, amount: Float((amountText.text!))! )
    
    betItemRef.setValue(betItem.toAnyObject())
    
    
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    FIRAuth.auth()!.addStateDidChangeListener { auth, user in
      guard let user = user else { return }
      self.user = User(authData: user)
      
    }
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
