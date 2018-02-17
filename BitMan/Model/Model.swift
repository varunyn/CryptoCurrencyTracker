//
//  Model.swift
//  BitMan
//
//  Created by Varun Yadav on 1/11/18.
//  Copyright © 2018 Varun Yadav. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

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
    var symbol:String
    
    init(name: String,rank:String,price_usd:String,price_btc:String,percentage:String,coinId:String,percentage1h:String,percentage7d:String,vol24h:String,symbol:String){
        self.name = name
        self.rank = rank
        self.price_btc = price_btc
        self.price_usd = price_usd
        self.percentage = percentage
        self.coinId = coinId
        self.percentage1h = percentage1h
        self.percentage7d = percentage7d
        self.vol24h = vol24h
        self.symbol = symbol
    }
}

class Coin{
    var name: String?
    var totalInvestment: Double?
    var quantity: Int?
    
    init(name: String?,totalInvestment: Double?,quantity: Int?){
        self.name = name
        self.totalInvestment = totalInvestment
        self.quantity = quantity
    }
}

class Item: Object {
    @objc dynamic var name : String = ""
    @objc dynamic var Price: Double = 0
}

class Coine: Object {

}
