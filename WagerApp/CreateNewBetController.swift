//
//  CreateNewBetContoller.swift
//  WagerApp
//
//  Created by Tyler Kaye, Michael Swart, Richard Bush, and William Chance on 4/2/17.
//

import UIKit
import Firebase
import GeoFire

class CreateNewBetController: UIViewController,  UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate  {

  @IBOutlet weak var wagerAmount: UITextField!
  @IBOutlet weak var wagerDescription: UITextField!
  @IBOutlet weak var wagerReason: UITextField!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var createBet: UIButton!
  @IBOutlet weak var reasonText: UITextField!
  let ref = FIRDatabase.database().reference(withPath: "Bets")
  @IBOutlet weak var amountText: UITextField!
  var user: User!
  var profile: Profile!
  @IBOutlet weak var catPicker: UIPickerView!
  var pickerData: [String] = [String]()
  let MAX_BET = Float(500.0)
  @IBOutlet weak var descriptionLabel: UITextField!
  let locationManager = CLLocationManager()
  var userLocation: CLLocation!


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
    let geofireRef = FIRDatabase.database().reference().child("bet_locations")
    let geoFire = GeoFire(firebaseRef: geofireRef)
    geoFire?.setLocation(userLocation, forKey: betItemRef.key)
    self.navigationController?.popViewController(animated: true)
  }
  
  /*func createLotsOfBets() {
    for _ in 1...500{
      let betItemRef = ref.childByAutoId()
      let betItem = BetItem(name: betItemRef.description(), description: "", challenger_uid: self.profile.key, challenger_name: "Mike", date_opened: Date().timeIntervalSinceReferenceDate, date_closed: Date().timeIntervalSinceReferenceDate, category: "Baseball", amount: 1)
      betItemRef.setValue(betItem.toAnyObject())
      let geofireRef = FIRDatabase.database().reference().child("bet_locations")
      let geoFire = GeoFire(firebaseRef: geofireRef)
      geoFire?.setLocation(userLocation, forKey: betItemRef.key)
    }
    
    for _ in 1...500 {
      let betItemRef = ref.childByAutoId()
      let betItem = BetItem(name: betItemRef.description(), description: "", challenger_uid: "-KhTGIJ_oaFE6F-3K74v", challenger_name: "tkaye407", date_opened: Date().timeIntervalSinceReferenceDate, date_closed: Date().timeIntervalSinceReferenceDate, category: "Other", amount: 1)
      betItemRef.setValue(betItem.toAnyObject())
      let geofireRef = FIRDatabase.database().reference().child("bet_locations")
      let geoFire = GeoFire(firebaseRef: geofireRef)
      geoFire?.setLocation(userLocation, forKey: betItemRef.key)
    }
  }*/

  func errorHandler(errorString: String) {
    let alertController = UIAlertController(title: "There was an Error creating the bet", message: errorString, preferredStyle: .alert)
    present(alertController, animated: true, completion: nil)
    let callOK = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(callOK)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    wagerDescription.delegate = self
    wagerAmount.delegate = self
    wagerReason.delegate = self 
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
  
    // some bs to allow me to mess with the keyboard
    NotificationCenter.default.addObserver(self, selector: #selector(CreateNewBetController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(CreateNewBetController.keyboardDidHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    self.scrollView.isScrollEnabled = false
    self.cancelButton.layer.cornerRadius = 5;
    self.createBet.layer.cornerRadius = 5;
    self.createBet.layer.borderColor = UIColor.white.cgColor
    self.createBet.layer.borderWidth = 1.5
    self.cancelButton.layer.borderColor = UIColor.white.cgColor
    self.cancelButton.layer.borderWidth = 1.5
    self.user = appDelegate.user
    self.profile = appDelegate.profile
    
    // Connect data:
    self.catPicker.delegate = self
    self.catPicker.dataSource = self
    self.pickerData = appDelegate.categories
    self.catPicker.reloadAllComponents()
    
    amountText.keyboardType = UIKeyboardType.numberPad
    
    self.locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    self.locationManager.requestLocation()

  }
  
  
  func keyboardWillShow(notification:NSNotification) {
    let userInfo:NSDictionary = notification.userInfo! as NSDictionary
    let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
    let keyboardRectangle = keyboardFrame.cgRectValue
    let keyboardHeight = keyboardRectangle.height
    let height = UIScreen.main.bounds.size.height-keyboardHeight+200//-keyboardHeight
    let width = UIScreen.main.bounds.size.width
      self.scrollView.isScrollEnabled = true
      self.scrollView.contentSize=CGSize(width: width, height: height)
      self.scrollView.flashScrollIndicators()
    
    //Looks for single or multiple taps.
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CreateNewBetController.dismissKeyboard))
    
    //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
    //tap.cancelsTouchesInView = false
    
    view.addGestureRecognizer(tap)
  }
  
  //Calls this function when the tap is recognized.
  func dismissKeyboard() {
    //Causes the view (or one of its embedded text fields) to resign the first responder status.
    view.endEditing(true)
  }
  
  func keyboardDidHide(notification:NSNotification) {
    self.scrollView.setContentOffset(CGPoint(x: 0, y:0), animated: true)
    self.scrollView.isScrollEnabled = false
  }
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.first {
      userLocation = location
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Failed to find user's location: \(error.localizedDescription)")
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

extension CreateNewBetController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
    print("in here")
    switch textField {
    case wagerReason:
      wagerDescription.becomeFirstResponder()
      break
    case self.wagerDescription:
      self.wagerAmount.becomeFirstResponder()
      break
    case self.wagerAmount:
      self.wagerAmount.resignFirstResponder()
    default:
       textField.resignFirstResponder()
      
    }
    return true
  }
}
