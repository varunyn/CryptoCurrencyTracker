//
//  CustomTabBarController.swift
//  BitMan
//
//  Created by Varun Yadav on 12/21/17.
//  Copyright © 2017 Varun Yadav. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class FetchedData{
    var name: String
    var rank:String
    var price_usd:String
    var price_btc:String
    var percentage:String
    var coinId:String
    var percentage1h:String
    var percentage7d:String
    var vol24h:String
    
    init(name: String,rank:String,price_usd:String,price_btc:String,percentage:String,coinId:String,percentage1h:String,percentage7d:String,vol24h:String){
        self.name = name
        self.rank = rank
        self.price_btc = price_btc
        self.price_usd = price_usd
        self.percentage = percentage
        self.coinId = coinId
        self.percentage1h = percentage1h
        self.percentage7d = percentage7d
        self.vol24h = vol24h
    }
}

class CustomTabBarController: UITabBarController {
  
    var model = [FetchedData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
}



