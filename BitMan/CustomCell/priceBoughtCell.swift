//
//  priceBoughtCell.swift
//  BitMan
//
//  Created by Varun Yadav on 2/12/18.
//  Copyright © 2018 Varun Yadav. All rights reserved.
//

import UIKit

class priceBoughtCell: UITableViewCell {

    
    @IBOutlet weak var priceBoughtTextField: UITextField!
     var Amount = Double()
     var delegate: priceBoughtDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        priceBoughtTextField.keyboardType = UIKeyboardType.decimalPad
        self.addDoneButtonOnKeyboard()
        priceBoughtTextField.text = String(Amount)
    }

    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar()
        doneToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(FourthCustomCell.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.priceBoughtTextField.inputAccessoryView = doneToolbar
        
    }
    @objc func doneButtonAction()
    {
        Amount = ((priceBoughtTextField.text ?? "0") as NSString).doubleValue
        self.priceBoughtTextField.resignFirstResponder()
        delegate?.purchasePrice(amount: Amount)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
