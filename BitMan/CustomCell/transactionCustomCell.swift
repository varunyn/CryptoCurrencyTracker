//
//  transactionCustomCell.swift
//  BitMan
//
//  Created by Varun Yadav on 2/14/18.
//  Copyright © 2018 Varun Yadav. All rights reserved.
//

import UIKit

class transactionCustomCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var quantityLabel: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var buyingPriceLabel: UILabel!
    
    @IBOutlet weak var percentageLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containerView.layer.cornerRadius = 5.0
        containerView.layer.borderColor  =  UIColor.white.cgColor
        containerView.layer.borderWidth = 2.0
        containerView.layer.shadowOpacity = 1.5
        containerView.layer.shadowColor =  UIColor.lightGray.cgColor
        containerView.layer.shadowRadius = 4.0
        containerView.layer.shadowOffset = CGSize(width:0, height: 10)
        containerView.layer.masksToBounds = false
        containerView.layer.shadowPath = UIBezierPath(rect: containerView.bounds).cgPath
//        containerView.backgroundColor = UIColor.white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
