//
//  BetViewController.swift
//  Grocr
//
//  Created by Tyler Kaye on 4/5/17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit

class BetViewController: UIViewController {
  @IBOutlet weak var betNameLabel: UILabel!
  @IBOutlet weak var betDescriptionLabel: UILabel!
  @IBOutlet weak var betChallengerLabel: UILabel!
  @IBOutlet weak var betCategoryLabel: UILabel!
  var bet: BetItem!
  var betName = "shit"

    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.betNameLabel.text = bet.name
        self.betCategoryLabel.text = bet.category
        self.betChallengerLabel.text = bet.challenger
        self.betDescriptionLabel.text = bet.amount

        // Do any additional setup after loading the view.
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
