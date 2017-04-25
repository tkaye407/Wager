//
//  SearchTableViewCell.swift
//  Wager
//
//  Created by Michael Swart on 4/24/17.
//
//

import Foundation

class SearchTableViewCell: UITableViewCell {
  
    @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var usernameLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
