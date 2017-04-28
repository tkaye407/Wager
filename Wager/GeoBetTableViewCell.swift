//
//  GeoBetTableViewCell.swift
//  Wager
//
//  Created by Tyler Kaye on 4/28/17.
//
//

import UIKit

class GeoBetTableViewCell: UITableViewCell {

  @IBOutlet weak var betNameLabel: UILabel!
  @IBOutlet weak var betChallengerLabel: UILabel!
  @IBOutlet weak var betAmountLabel: UILabel!

  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
