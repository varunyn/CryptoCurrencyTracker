//
//  CustomAllPageCell.swift
//  BitMan
//
//  Created by Varun Yadav on 12/5/17.
//  Copyright © 2017 Varun Yadav. All rights reserved.
//

import UIKit

class CustomAllPageCell: UITableViewCell {

    

    
    @IBOutlet weak var percentLabel: UILabel!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var rank: UILabel!
    
    @IBOutlet weak var priceUS: UILabel!
    
    @IBOutlet weak var priceBTC: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
