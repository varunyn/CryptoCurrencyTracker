//
//  FourthCustomCell.swift
//  BitMan
//
//  Created by Varun Yadav on 2/9/18.
//  Copyright © 2018 Varun Yadav. All rights reserved.
//

import UIKit

class FourthCustomCell: UITableViewCell {

    @IBOutlet weak var amountField: UITextField!
    
    @IBOutlet weak var amountBoughtTextField: UITextField!
    
    
    var Amount = Double()
    
    var delegate: amountDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        amountField.keyboardType = .numberPad
        self.addDoneButtonOnKeyboard()
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
        
        self.amountField.inputAccessoryView = doneToolbar
        
    }
    @objc func doneButtonAction()
    {
        Amount = ((amountField.text ?? "0") as NSString).doubleValue
        self.amountField.resignFirstResponder()
        delegate?.NumberofQuantity(amount: Amount)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
