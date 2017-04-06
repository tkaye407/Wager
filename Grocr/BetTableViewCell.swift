//
//  BetTableViewCell.swift
//  Grocr
//
//  Created by Tyler Kaye on 4/6/17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit

class BetTableViewCell: UITableViewCell {
  @IBOutlet weak var betNameLabel: UILabel!
  @IBOutlet weak var betAmountLabel: UILabel!
  @IBOutlet weak var betChallengerLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
