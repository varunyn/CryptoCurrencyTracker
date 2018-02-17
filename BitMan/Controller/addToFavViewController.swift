//
//  addToFavViewController.swift
//  BitMan
//
//  Created by Varun Yadav on 2/9/18.
//  Copyright © 2018 Varun Yadav. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Firebase
import NotificationBannerSwift
import RealmSwift

class addToFavViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, pickControllerDeletegate,pairPickControllerDeletegate,amountDelegate,priceBoughtDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var totalPriceInUsdLabel: UILabel!
    
    
    let toolbar = UIToolbar()
    let datePicker = UIDatePicker()
    
    let realm = try! Realm()
    
    var exchangeName:String = "Exchange"
    var symbolName = ""
    var pairNamed = "Pair"
    var prices = Double()
    var totalAmount = Double()
    var buyingPrice: Double? = 0
    var priceURL: String? = ""
    var date: String? = ""
    var coinName: String? = ""
    var coinSymbol:String? = ""
    var quoteName:String = ""
    var totalPriceInUsd:Double = 0
    var nameInRealm = [Item]()
    var buyingPriceInUsd: Double = 0
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        guard let userkey = Auth.auth().currentUser?.uid else {return}
        print("Get from firebase")
        
        let addedToPortfolioBanner = NotificationBanner(title: "Saved", subtitle: "Added to portfolio", style: .success)
        let addAllFieldBanner =  NotificationBanner(title: "Please add all the fields", subtitle: "", style: .warning)
        
        if pairNamed != "" {
            if self.buyingPrice != 0 && self.priceURL != "" && self.pairNamed != "" && self.coinName != nil && totalAmount != 0 && totalPriceInUsd != 0 && buyingPriceInUsd != 0 && !nameInRealm.isEmpty{
                let totalPrice = String(self.totalAmount * self.buyingPrice! )
                let post = [
                    "url" : self.priceURL!,
                    "buyingPrice": buyingPriceInUsd,
                    "date": self.date!,
                    "quantity": self.totalAmount,
                    "totalPrice": totalPriceInUsd
                    ] as [String : Any]
                
                Database.database().reference().child("users")
                    .child(userkey)
                    .child("PortFolio")
                    .child("\(self.coinName!)")
                    .childByAutoId()
                    .setValue(post) { (error, database) in
                        if error != nil {
                            print(error.debugDescription)
                        }
                }
                addedToPortfolioBanner.show()
                self.navigationController?.popViewController(animated: true)
            } else{
                addAllFieldBanner.show()
            }
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
        addButton.layer.cornerRadius = 0.5 * addButton.bounds.size.width
        addButton.clipsToBounds = true
        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        addButton.layer.masksToBounds = false
        addButton.layer.shadowRadius = 2.0
        addButton.layer.shadowOpacity = 0.5
        
        view.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.backgroundColor = .white
        datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        datePicker.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        datePicker.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        datePicker.heightAnchor.constraint(equalToConstant: 200).isActive = true
        datePicker.datePickerMode = .date
        datePicker.isHidden = true
    }
    
    func textChanged(text: String,route:String) {
        nameInRealm.removeAll()
        exchangeName = text
        symbolName = route
        totalAmount = 0
        self.tableView.reloadData()
    }
    
    func pairName(name: String) {
        pairNamed = name
        totalAmount = 0
        prices = 0
        
        let pairURL = "https://api.cryptowat.ch/pairs/" + pairNamed
        Alamofire.request(pairURL).responseJSON { response in
            if let json = response.result.value {
                let json = JSON(json)
                let name = String(describing: json["result"]["base"]["name"])
                self.quoteName = String(describing: json["result"]["quote"]["name"])
                let symbol = String(describing: json["result"]["base"]["symbol"])
                self.coinName = name
                self.coinSymbol = symbol
                print(self.coinSymbol!,"coinSymbol")
                print(self.quoteName,"quoteName")
            }
            
            
            if self.quoteName != "" && self.quoteName != "United States dollar" {
                
                if self.quoteName == "euro" || self.quoteName == "British Pound" || self.quoteName == "Japanese Yen" || self.quoteName == "Canadian dollar"{
                    self.pairNamed = ""
                    let incorrectPair =  NotificationBanner(title: "USD Only", subtitle: "Please select different Pair", style: .warning)
                    incorrectPair.show()
                } else{
                    
                    let coin = self.realm.objects(Item.self).filter("name ='\(self.quoteName.lowercased())'")
                    
                    let baseCoin:Results<Item> = self.realm.objects(Item.self).filter("name ='\(self.coinName!.lowercased())'")
                    
                    if !baseCoin.isEmpty {
                        print("Not Empty")
                        self.nameInRealm.append(coin[0])
                    } else{
                        print("Empty")
                        self.pairNamed = ""
                        let incorrectPair =  NotificationBanner(title: "Incorrect Pair", subtitle: "Please select different Pair", style: .warning)
                        incorrectPair.show()
                    }
                }
            }
            
            
            
            if self.coinSymbol != nil {
                
                self.priceURL = "https://api.cryptowat.ch/markets" + "/" + "\(self.symbolName)" + "/" + "\(self.pairNamed)"  + "/price"
                print(self.priceURL as Any)
                
                Alamofire.request(self.priceURL!).responseJSON { response in
                    if let json = response.result.value {
                        let json = JSON(json)
                        let price = json["result"]["price"].double
                        if price != nil {
                            self.prices = price!
                        } else {
                            self.prices = 0
                        }
                    }
                    self.tableView.reloadData()
                }
                
            }
        }
    }
    
    func NumberofQuantity(amount: Double) {
        totalAmount = amount
    }
    func purchasePrice(amount: Double) {
        buyingPrice = amount
        self.tableView.reloadData()
    }
    
    @objc func donePicker() {
        print("Picker displayed")
        datePicker.isHidden = false
        toolbar.isHidden = false
        datePicker.datePickerMode = .date
        
        toolbar.barStyle = UIBarStyle.blackTranslucent
        view.addSubview(toolbar)
        
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.bottomAnchor.constraint(equalTo: datePicker.topAnchor).isActive = true
        toolbar.leadingAnchor.constraint(equalTo: datePicker.leadingAnchor).isActive = true
        toolbar.trailingAnchor.constraint(equalTo: datePicker.trailingAnchor).isActive = true
        toolbar.heightAnchor.constraint(equalToConstant: 40).isActive = true
        toolbar.isUserInteractionEnabled = true
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker))
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
    }
    
    @objc func donedatePicker(){
        print("Done button tapped")
        let todayDate = Date()
        let indexPath = IndexPath(row: 2, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as? ThirdCustomCell
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        let currentDate = formatter.string(from: todayDate)
        date = formatter.string(from: datePicker.date)
        
        print(formatter.string(from: datePicker.date))
        
        let dateBanner =  NotificationBanner(title: "Incorrect Date", subtitle: "We don't provide market prediction service yet", style: .warning)
        
        if date! > currentDate {
            dateBanner.show()
        } else {
            cell!.dateLabel.text = formatter.string(from: datePicker.date)
            datePicker.isHidden = true
            toolbar.isHidden = true
        }
    }
    
    @objc func cancelDatePicker(){
        datePicker.isHidden = true
        toolbar.isHidden = true
        print("Cancel button tapped")
        self.view.endEditing(true)
    }
    
    // TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "firstCustomCell") as! FirstCustomCell
            cell.exchangeLabel.text = exchangeName
            return cell
        }
        else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "secondCustomCell") as! SecondCustomCell
            cell.tradingPairLabel.text = pairNamed
            return cell
        }
        else if indexPath.row == 2 {
            let Thirdcell = tableView.dequeueReusableCell(withIdentifier: "thirdCustomCell") as! ThirdCustomCell
            return Thirdcell
        }
        else if indexPath.row == 3 {
            let Fourthcell = tableView.dequeueReusableCell(withIdentifier: "fourthCustomCell") as! FourthCustomCell
            Fourthcell.delegate = self
            return Fourthcell
        }
        else if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "fifthCustomCell") as! fifthCustomCell
            if prices == 0 {
                cell.priceLabel.text  = "Unavailable"
            }
            cell.priceLabel.text  =  String(format:"%f",prices)
            return cell
        } else if indexPath.row == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "priceBoughtCell") as! priceBoughtCell
            cell.delegate = self
            if buyingPrice == 0 {
                cell.priceBoughtTextField.text = String(format:"%f",prices)
            } else {
                cell.priceBoughtTextField.text = String(format:"%f",buyingPrice!)
                if !nameInRealm.isEmpty{
                    buyingPriceInUsd = buyingPrice! * nameInRealm[0].Price
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "totalAmountCell") as! totalAmountCell
            var totalPrice:String = ""
            totalPrice = String(totalAmount * buyingPrice! )
            cell.totalAmountLabel.text  = totalPrice
            
            if quoteName != "" || quoteName == "United States dollar" {
                if !nameInRealm.isEmpty{
                    totalPriceInUsd = nameInRealm[0].Price * Double(totalPrice)!
                    print(totalPriceInUsd)
                } else {
                    totalPriceInUsd = Double(totalPrice)!
                }
                
            }
            totalPriceInUsdLabel.text = String(totalPriceInUsd)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2{
            donePicker()
        } else if indexPath.row == 0 {
            let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
            let exchangePickerVC = StoryBoard.instantiateViewController(withIdentifier: "pickerViewController") as! pickerViewController
            exchangePickerVC.delegate = self
            self.navigationController?.pushViewController(exchangePickerVC, animated: true)
        }
        else if indexPath.row == 1 {
            let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
            let pairPickerVC = StoryBoard.instantiateViewController(withIdentifier: "pairPickerController") as! pairPickerController
            pairPickerVC.delegate = self
            pairPickerVC.exchangeID = symbolName
            self.navigationController?.pushViewController(pairPickerVC, animated: true)
        }
    }
    
    func gettingPairPrice(){
        
    }
}

protocol pickControllerDeletegate: class {
    func textChanged(text:String, route:String) -> ()
}
protocol pairPickControllerDeletegate: class {
    func pairName(name:String) -> ()
}
protocol amountDelegate: class {
    func NumberofQuantity(amount:Double) -> ()
}
protocol priceBoughtDelegate: class {
    func purchasePrice(amount:Double) -> ()
}



