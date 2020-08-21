//
//  LocationWeatherTableViewCell.swift
//  Weather
//
//  Created by horkimlong on 6/24/20.
//  Copyright © 2020 horkimlong. All rights reserved.
//

import UIKit
import gooey_cell

class LocationWeatherTableViewCell: GooeyEffectTableViewCell {

    @IBOutlet var backGroundImage: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var sunOrMoonImage: UIImageView!
    @IBOutlet weak var locationSymbol: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        cityLabel.font = UIFont(name: "Roboto-Regular", size: 14)
        
        backGroundImage.layer.cornerRadius = 20
        backGroundImage.layer.masksToBounds = true
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
