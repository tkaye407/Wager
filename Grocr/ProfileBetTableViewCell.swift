//
//  ProfileBetTableViewCell.swift
//  Grocr
//
//  Created by William Chance on 4/23/17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//


import UIKit

class ProfileBetTableViewCell: UITableViewCell {
  
  @IBOutlet weak var betNameLabel: UILabel!
  @IBOutlet weak var actionButton: UIButton!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}

