//
//  portFolioViewController.swift
//  BitMan
//
//  Created by Varun Yadav on 2/12/18.
//  Copyright © 2018 Varun Yadav. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import SwiftyJSON
import NotificationBannerSwift
import RealmSwift

class portFolioViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var portFolioAmountLabel: UILabel!
    
    @IBOutlet weak var percentageLabel: UILabel!
    
    let realm = try! Realm()
    
    var names = [String]()
    var coins = [Coin]()
    
    var currentTotalPrice = [Double]()
    
    var nameInRealm = [Item?]()
    
    var percentageInDifferencePlus:Double = 0
    
    @IBOutlet weak var addButton: UIButton!
    @IBAction func addButtonPressed(_ sender: Any) {
        let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let pairPickerVC = StoryBoard.instantiateViewController(withIdentifier: "addToFavViewController") as! addToFavViewController
        self.navigationController?.pushViewController(pairPickerVC, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("PortFolio ViewDidLoad")
        
        tableView.tableFooterView = UIView(frame: .zero)
        
        addButton.layer.cornerRadius = 0.5 * addButton.bounds.size.width
        addButton.clipsToBounds = true
        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        addButton.layer.masksToBounds = false
        addButton.layer.shadowRadius = 2.0
        addButton.layer.shadowOpacity = 0.5
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "portFolioCustomCell") as! portFolioCustomCell
        cell.nameLabel.text = coins[indexPath.row].name!
        if !currentTotalPrice.isEmpty {
            cell.priceLabel.text = String(describing: currentTotalPrice[indexPath.row])
        }
        cell.quantityLabel.text = String(coins[indexPath.row].quantity!)
        cell.priceBoughtAtLabel.text = String(describing: coins[indexPath.row].totalInvestment!)
        if !currentTotalPrice.isEmpty {
            if currentTotalPrice[indexPath.row] >  coins[indexPath.row].totalInvestment! {
                let difference = currentTotalPrice[indexPath.row] - coins[indexPath.row].totalInvestment!
                let percentageDifference  = (difference * 100) / currentTotalPrice[indexPath.row]
                cell.percentageLabel.text = String(Int(percentageDifference)) + "%"
                cell.percentageLabel.textColor = UIColor(hue: 0.3667, saturation: 0.43, brightness: 0.78, alpha: 1.0)
            }
            
            if currentTotalPrice[indexPath.row] <  coins[indexPath.row].totalInvestment! {
                let difference =  coins[indexPath.row].totalInvestment! - currentTotalPrice[indexPath.row]
                let percentageDifference  = (difference * 100) / coins[indexPath.row].totalInvestment!
                cell.percentageLabel.text = String(Int(percentageDifference)) + "%"
                cell.percentageLabel.textColor = UIColor.red
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let transactionVC = StoryBoard.instantiateViewController(withIdentifier: "transactionViewController") as! transactionViewController
        transactionVC.name = coins[indexPath.row].name!
        
        self.navigationController?.pushViewController(transactionVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let userkey = Auth.auth().currentUser?.uid else {return}
        
        let name = coins[indexPath.row].name!
        
        let node =  Database.database().reference().child("users")
            .child(userkey)
            .child("PortFolio")
            .child("\(name)")
        
        node.removeValue()
        
        let banner = NotificationBanner(title: "Transaction", subtitle: "Deleted", style: .danger)
        banner.show()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            banner.dismiss()
        }
        
        self.coins.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        loadData()
        //        calculateCurrentMarktetValue()
    }
    
    func loadData(){
        
        names = [String]()
        coins = [Coin]()
        nameInRealm = [Item]()
        
        guard let userkey = Auth.auth().currentUser?.uid else {return}
        Database.database().reference().child("users")
            .child(userkey)
            .child("PortFolio")
            .observeSingleEvent(of: .value, with: {(snapshot) in
                
                let value = snapshot.value as? NSDictionary
                if value != nil{
                    let coinNames = value?.allKeys as! [String]
                    
                    coinNames.forEach({ (name) in
                        self.names.append(name)
                        let coin = self.realm.objects(Item.self).filter("name ='\(name.lowercased())'")
                        print(coin)
                        if !coin.isEmpty{
                            self.nameInRealm.append(coin[0])
                        }
                        
                        Database.database().reference().child("users")
                            .child(userkey)
                            .child("PortFolio")
                            .child("\(name)")
                            .observeSingleEvent(of: .value, with :{(snapshot) in
                                
                                let value = snapshot.value as? NSDictionary
                                let keys = value?.allKeys as? [String]
                                
                                var buyingPrice:Double = 0
                                var totalQuantity = 0
                                
                                for index in 0...(keys!.count-1) {
                                    
                                    let urlss = value![keys![index]] as? [String:Any]
                                    
                                    //                                    buyingPrice += (urlss!["totalPrice"] as! NSString).doubleValue
                                    buyingPrice += (urlss!["totalPrice"] as! NSNumber).doubleValue
                                    totalQuantity += (urlss!["quantity"] as! NSNumber).intValue
                                    
                                    if index == keys!.count-1 {
                                        self.coins.append(Coin(name:name,totalInvestment:buyingPrice, quantity:totalQuantity))
                                    }
                                }
                                self.calculateCurrentMarktetValue()
                                self.tableView.reloadData()
                            })
                    })
                }
                
            })
    }
    
    func calculateCurrentMarktetValue(){
        var money:Double = 0
        var totalMoney:Double = 0
        var mon:Double = 0
        currentTotalPrice = [Double]()
        if !nameInRealm.isEmpty{
            for index in (0..<coins.count) {
                money += coins[index].totalInvestment!
            }
            for index in 0..<coins.count{
                var price:Double? = 0
                if  nameInRealm[index]?.Price != nil {
                    price =  (nameInRealm[index]?.Price)
                }
                    let quantity = Double(coins[index].quantity!)
                    mon = price! * quantity
                    currentTotalPrice.append(mon)
                    totalMoney += mon
                
            }
        }
        if totalMoney > money {
            let difference =  totalMoney - money
            percentageInDifferencePlus = (difference * 100)/money
            self.percentageLabel.textColor = UIColor(hue: 0.3667, saturation: 0.43, brightness: 0.78, alpha: 1.0)
            print(percentageInDifferencePlus)
        } else {
            let difference =  money - totalMoney
            if difference != 0 {
                percentageInDifferencePlus = (difference * 100)/money
            }
            self.percentageLabel.textColor = UIColor.red
        }
        self.portFolioAmountLabel.text = "$ " + String(Int(totalMoney))
        self.percentageLabel.text = String(Int(percentageInDifferencePlus)) + "%"
    }
}




