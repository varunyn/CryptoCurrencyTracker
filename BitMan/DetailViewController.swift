//
//  DetailViewController.swift
//  BitMan
//
//  Created by Varun Yadav on 12/12/17.
//  Copyright © 2017 Varun Yadav. All rights reserved.
//

import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
//    func networkCall(){
//    }
    
    
}



class DetailViewController: UIViewController {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
    @IBOutlet weak var forName: UILabel!
    
     var NewData = [FetchedData]()
    var c = ""
    @IBOutlet weak var forUSD: UILabel!
    
    @IBOutlet weak var forBTC: UILabel!
    
    @IBOutlet weak var for1H: UILabel!
    
    @IBOutlet weak var for24H: UILabel!
    
    @IBOutlet weak var for7D: UILabel!
    
    @IBOutlet weak var for24hVol: UILabel!
    
  
    
    @IBAction func USDTextField(_ sender: Any) {
        

//        var mul = Int(USDtextField1.text!)
//        print(mul)
//        var a = Int(c)
//        print(a)
//        var b = a! * mul!
//        print(b)
//        
//        CurrencyTextfield.text = String(b)

    }
    
    
    
    @IBOutlet weak var USDtextField1: UITextField!
    
    
    @IBOutlet weak var CurrencyTextfield: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        forUSD.text = NewData[0].price_usd
         forBTC.text = NewData[0].price_btc
         forName.text = NewData[0].name
        for1H.text = NewData[0].percentage1h + "%"
         for24H.text = NewData[0].percentage
         for7D.text = NewData[0].percentage7d + "%"
         for24hVol.text = NewData[0].vol24h
        
        
        
        USDtextField1.text = "1"
        CurrencyTextfield.text = NewData[0].price_usd
        
        let change1h = NewData[0].percentage1h
         let change24h = NewData[0].percentage
         let change7d = NewData[0].percentage7d
        
        for1H.textColor = change1h.range(of: "-") != nil ? .red : .green
         for24H.textColor = change24h.range(of: "-") != nil ? .red : .green
         for7D.textColor = change7d.range(of: "-") != nil ? .red : .green
        
        // Do any additional setup after loading the view.
        
       USDtextField1.keyboardType = UIKeyboardType.numberPad
        
        //HIDE KEYBOARD
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
       NewData = [FetchedData]()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
