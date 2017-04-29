//
//  FilterViewController.swift
//  Wager
//
//  Created by Tyler Kaye on 4/28/17.
//
//

import UIKit

class FilterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
  
  @IBOutlet weak var radiusLabel: UILabel!
  @IBOutlet weak var radiusSlider: UISlider!
  @IBOutlet weak var friendsOption: UISegmentedControl!
  @IBOutlet weak var applyFiltersButton: UIButton!
  @IBOutlet weak var geoOption: UISegmentedControl!
  @IBOutlet weak var categoryOption: UIPickerView!
  @IBOutlet weak var typeOption: UISegmentedControl!
  var fint = 100
  var gint = 100
  var tint = 100
  var rad: Float = 100000.0
  let cRef = FIRDatabase.database().reference(withPath: "Categories")
  var categories: [String] = [String]()



    override func viewDidLoad() {
        super.viewDidLoad()
      
        // Connect data:
        self.categoryOption.delegate = self
        self.categoryOption.dataSource = self
      
        categories.append("All")
        cRef.observe(.value, with: { snapshot in
          for item in snapshot.children {
            let currCat = item as! FIRDataSnapshot
            let snapshotValue = currCat.value as! String
            self.categories.append(snapshotValue)
          }
          self.categoryOption.reloadAllComponents();
        })
      
      if (fint != 100) {
        friendsOption.selectedSegmentIndex = fint
      }
      if (gint != 100) {
        geoOption.selectedSegmentIndex = gint
      }
      if (tint != 100) {
        typeOption.selectedSegmentIndex = tint
      }
      
      radiusSlider.minimumValue = 1.00
      radiusSlider.maximumValue = 50.00
      radiusSlider.isContinuous = false
      
      if (abs(rad - 100000.0) > 0.001) {
        self.radiusSlider.value = Float(rad)
      }
      else {
        self.radiusSlider.value = 1.0
      }
      let slider_mi = self.radiusSlider.value
      let radius = Int(slider_mi)
      self.radiusLabel.text = "Radius: \(radius) miles"

      
      

        // Do any additional setup after loading the view.
    }
  
  @IBAction func radiusDidChange(_ sender: Any) {
    let slider_mi = self.radiusSlider.value
    //let slider_mi = slider_km * 0.621371
    let radius = Int(slider_mi)
    radiusLabel.text = "Radius: \(radius) miles"
  }
  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      super.prepare(for: segue, sender: sender)
      if (segue.identifier == "backToList") {
        let vc = segue.destination as! BetListTableViewController
        let cat = categories[categoryOption.selectedRow(inComponent: 0)]
        if (cat == "All") {
          vc.channelName = ""
        }
        else {
          vc.channelName = cat
        }
        vc.friendsOnly = friendsOption.selectedSegmentIndex
        vc.betType = typeOption.selectedSegmentIndex
        if (geoOption.selectedSegmentIndex == 1) {vc.geo = true}
        else {vc.geo = false}
        vc.radius = self.radiusSlider.value

      }

      
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
  
  @IBAction func applyFilters(_ sender: Any) {
    performSegue(withIdentifier: "backToList", sender: self)
  }
  
  
  // The number of rows of data
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
  {
    return categories.count
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return categories[row]
  }

}
