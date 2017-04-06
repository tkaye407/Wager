//
//  BetViewController.swift
//  Grocr
//
//  Created by Tyler Kaye on 4/5/17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit

class BetViewController: UIViewController {
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var challengerLabel: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var takeBetButton: UIButton!
  
  
  var bet: BetItem!
  var betName = "shit"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameLabel.text = bet.name
        self.categoryLabel.text = bet.category
        self.challengerLabel.text = bet.challenger
        self.descriptionLabel.text = bet.amount
      
      if (!bet.completed) {
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
    if (!bet.completed) {
      self.nameLabel.text = "SHIT"
      self.takeBetButton.setTitle("Accepted", for: UIControlState.normal)
      self.takeBetButton.isEnabled = false;
      self.bet.completed = true
      
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
