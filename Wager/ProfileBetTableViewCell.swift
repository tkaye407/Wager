//
//  ProfileBetTableViewCell.swift
//
//  Created by William Chance on 4/23/17.
//


import UIKit

class ProfileBetTableViewCell: UITableViewCell {
  
  @IBOutlet weak var betNameLabel: UILabel!
  @IBOutlet weak var challengerLabel: UILabel!
  @IBOutlet weak var amountLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}

