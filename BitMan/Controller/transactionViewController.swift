//
//  transactionViewController.swift
//  BitMan
//
//  Created by Varun Yadav on 2/14/18.
//  Copyright © 2018 Varun Yadav. All rights reserved.
//

import UIKit
import Firebase
import NotificationBannerSwift
import RealmSwift

class transactionViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    var name =  ""
    
    @IBOutlet weak var tableView: UITableView!
    
    var transactions  = [transactionDetails]()
    
    var sortedTransactions = [transactionDetails]()
    
    let realm = try! Realm()
    
    var keys = [Any]()
    
    var nameInRealm = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let coin = self.realm.objects(Item.self).filter("name = '\(name.lowercased())'")
        self.nameInRealm.append(coin[0])
        
        navigationItem.title = "Transactions"
        guard let userkey = Auth.auth().currentUser?.uid else {return}
        Database.database().reference().child("users")
            .child(userkey)
            .child("PortFolio")
            .child("\(name)")
            .observeSingleEvent(of: .value, with: { (snapshot) in
                
                let values = snapshot.value as? NSDictionary
                let keys = values?.allKeys as? [String]
                
                for index in 0...(keys!.count-1) {
                    self.keys.append(values?.allKeys[index] as? String )
                    
                    let val = values![keys![index]] as? [String:Any]
                    let date = (val!["date"]) as! String
                    let quantity = (val!["quantity"] as! NSNumber).intValue
                    let buyingprice = (val!["buyingPrice"] as! NSNumber).doubleValue
                    
                    self.transactions.append(transactionDetails(date: date, quantity: quantity, buyingPrice: buyingprice))
                }
                self.sortedTransactions =  self.transactions.sorted { (initial, next) -> Bool in
                    return initial.date! < next.date!}
                
                self.tableView.reloadData()
            })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedTransactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCustomCell") as! transactionCustomCell
        cell.dateLabel.text = sortedTransactions[indexPath.row].date!
        cell.quantityLabel.text =  String(sortedTransactions[indexPath.row].quantity)
        cell.buyingPriceLabel.text = String(sortedTransactions[indexPath.row].buyingPrice)
        
        if nameInRealm[0].Price > sortedTransactions[indexPath.row].buyingPrice {
            let difference = nameInRealm[0].Price - sortedTransactions[indexPath.row].buyingPrice
            let percentageDifference  = (difference * 100) / nameInRealm[0].Price
            cell.percentageLabel.text = String(Int(percentageDifference)) + "%"
            cell.percentageLabel.textColor = UIColor(hue: 0.3667, saturation: 0.43, brightness: 0.78, alpha: 1.0)
        } else {
            let difference = sortedTransactions[indexPath.row].buyingPrice - nameInRealm[0].Price
            let percentageDifference  = (difference * 100) / sortedTransactions[indexPath.row].buyingPrice
            cell.percentageLabel.text = String(Int(percentageDifference)) + "%"
            cell.percentageLabel.textColor = UIColor.red
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let userkey = Auth.auth().currentUser?.uid else {return}
        
        let key = keys[indexPath.row]
        let node =  Database.database().reference().child("users")
            .child(userkey)
            .child("PortFolio")
            .child("\(name)")
            .child(key as! String)
        
        node.removeValue()
        
        let banner = NotificationBanner(title: "Transaction", subtitle: "Deleted", style: .danger)
        banner.show()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            banner.dismiss()
        }
        
        self.sortedTransactions.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
}

class transactionDetails {
    var date:String?
    var quantity:Int
    var buyingPrice:Double
    
    init(date:String?, quantity:Int, buyingPrice:Double){
        
        self.date = date
        self.quantity = quantity
        self.buyingPrice = buyingPrice
    }
}
