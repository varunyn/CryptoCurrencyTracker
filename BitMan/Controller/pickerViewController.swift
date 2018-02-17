//
//  pickerViewController.swift
//  BitMan
//
//  Created by Varun Yadav on 2/12/18.
//  Copyright © 2018 Varun Yadav. All rights reserved.
//

import UIKit

class pickerViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    
    var delegate: pickControllerDeletegate?
    
    @IBOutlet weak var tableView: UITableView!
    
    var exchanges = [Exchange(name: "Binance", symbol: "binance"),Exchange(name: "GDAX", symbol: "gdax"),Exchange(name: "Bitfinex", symbol: "bitfinex"),Exchange(name: "Bitstamp", symbol: "bitstamp"),Exchange(name: "Kraken", symbol: "kraken"),Exchange(name: "Poloniex", symbol: "poloniex"),Exchange(name: "Bittrex", symbol: "bittrex")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exchanges.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pickerCustomCell") as! pickerCustomCell
        cell.nameLabel.text = exchanges[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.textChanged(text: exchanges[indexPath.row].name,route: exchanges[indexPath.row].symbol)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

class Exchange {
    var name:String
    var symbol:String
    
    init(name:String,symbol:String){
        self.name = name
        self.symbol = symbol
    }
}

