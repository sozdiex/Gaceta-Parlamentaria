//
//  ActivarVotoCell.swift
//  Gaceta Parlamentaria
//
//  Created by Armando Trujillo on 13/03/15.
//  Copyright (c) 2015 RedRabbit. All rights reserved.
//

import UIKit

class ActivarVotoCell: UITableViewCell {

    @IBOutlet var label : UILabel!
    @IBOutlet var boton : UIButton!
    @IBOutlet var viewSeperator : UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
