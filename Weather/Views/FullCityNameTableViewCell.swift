//
//  FullCityNameTableViewCell.swift
//  Weather
//
//  Created by horkimlong on 6/28/20.
//  Copyright © 2020 horkimlong. All rights reserved.
//

import UIKit

class FullCityNameTableViewCell: UITableViewCell {

    @IBOutlet weak var fullCityNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        fullCityNameLabel.font = UIFont(name: "Roboto-Regular", size: 18)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
