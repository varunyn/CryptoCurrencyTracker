//
//  FavViewController.swift
//  BitMan
//
//  Created by Varun Yadav on 12/6/17.
//  Copyright © 2017 Varun Yadav. All rights reserved.
//

import UIKit
import SwiftyJSON
import Firebase
import NotificationBannerSwift

class FavViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    var  loadedData = [String]()
   
    var NewData = [FetchedData]()
    
    var NewData1 = [FetchedData]()
    
    var refresher: UIRefreshControl!
    @IBOutlet weak var FavTableView: UITableView!
    
/*  ---------------------- Start of ViewDiDLoad  ----------------------  */
    
    override func viewDidLoad() {

        super.viewDidLoad()
     
        FavTableView.register(UINib(nibName: "CustomAllPageCell", bundle: nil),forCellReuseIdentifier: "AllPageCell")
        
        getFromFirebase()
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(AllPageController.populate), for: UIControlEvents.valueChanged)
        FavTableView.addSubview(refresher)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadFromMain), name: NSNotification.Name(rawValue: "load"), object: nil)
        
    }
    
/*  ---------------------- END of ViewDiDLoad  ----------------------  */

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        FavTableView.setContentOffset(CGPoint.zero, animated: true)
        
    }
//    override func viewWillAppear(_ animated: Bool) {
//      NewData1 = (self.tabBarController as! CustomTabBarController).model
//
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//
//        for j in 0..<NewData1.count{
//            for i in loadedData{
//                if i == NewData1[j].name {
//                    NewData.append(NewData1[j])
//                }
//            }
////            print(NewData1[j].name)
//        }
//
//    }
    
/*  ---------------------- Start of TableView  ----------------------  */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loadedData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllPageCell", for: indexPath) as! CustomAllPageCell
        
        cell.name.text = NewData[indexPath.row].name
        cell.rank.text = NewData[indexPath.row].rank
        cell.priceUS.text = NewData[indexPath.row].price_usd
        cell.priceBTC.text = NewData[indexPath.row].price_btc

        cell.percentLabel.text = NewData[indexPath.row].percentage

        let change = cell.percentLabel.text

        cell.percentLabel.textColor = change?.range(of: "-") != nil ? .red : .green

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 80.0;//Choose your custom row height
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let userkey = Auth.auth().currentUser?.uid else {return}
        
        let CurrencyName = self.loadedData[indexPath.row]
        
       Database.database().reference().child("users")
            .child(userkey)
            .child("Favorite")
            .queryOrdered(byChild: "name")
            .queryEqual(toValue: CurrencyName)
           
        .observeSingleEvent(of: .childAdded, with: { (snapshot) in
                
                
                snapshot.ref.removeValue(completionBlock: { (error, reference) in
                    if error != nil {
                        print("There has been an error:\(String(describing: error))")
                    } else{
                        print("removed")
                    }
                })
                
            })

        let banner = NotificationBanner(title: "\(CurrencyName)", subtitle: "Deleted", style: .danger)
        banner.show()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            banner.dismiss()
        }
        
            self.loadedData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let SecondVC = StoryBoard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
   
        SecondVC.NewData = [NewData[indexPath.row]]
       
        self.navigationController?.pushViewController(SecondVC, animated: true)
    }
    
/*  ---------------------- END of TABLEVIEW  ----------------------  */
    
    
    // FUNCTION FOR NETWORK CALL FROM API
    
    func getValue(){
     
        NewData = [FetchedData]()

        print("URL")
        for i in loadedData{

        let finalUrl = "https://api.coinmarketcap.com/v1/ticker/" + "\(i)" + "/"

        let url = URL.init(string: finalUrl)

        do{
            let response = try Data.init(contentsOf: url!)

            let json = JSON(data: response)
            let j = 0

                let title = String(describing: json[j]["name"])

                let rank = String(describing: json[j]["rank"])

                let USD = String(describing: json[j]["price_usd"])

                let BTC = String(describing: json[j]["price_btc"])

                let percent = String(describing: json[j]["percent_change_24h"])

                let percent1h = String(describing: json[j]["percent_change_1h"])

                let percent7d = String(describing: json[j]["percent_change_7d"])

                let Vol = String(describing: json[j]["24h_volume_usd"])

                let ID = String(describing: json[i]["id"])

                let c = "%"

                let finalper = "\(percent)" + c

            self.NewData.append(FetchedData(name: title,rank: rank, price_usd:USD, price_btc:BTC,percentage:finalper, coinId:ID, percentage1h: percent1h, percentage7d: percent7d, vol24h: Vol))

        } catch let error {
            print(error)
        }
     }
        FavTableView.reloadData()
    }
    
    // FUNCTION FOR NETWORK CALL FROM API
    
    func getFromFirebase(){
        loadedData = [String]()
        
        guard let userkey = Auth.auth().currentUser?.uid else {return}
        print("Get from firebase")
        
        Database.database().reference().child("users")
                                       .child(userkey)
                                       .child("Favorite")
                                       .observe(.childAdded, with:
    { (snapshot) in

        if let getData = snapshot.value as? [String:Any] {
        let wins = getData["name"] as? String
        self.loadedData.append(wins!)
        
        print(wins!)
        }
    }, withCancel: { (error) in
                      print(error.localizedDescription)
                   })
  
//        getValue()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.00, execute: { self.getValue()  })
        
    }
    
    @objc func reloadFromMain(){
        getFromFirebase()
    }
    
      @objc func initializeLoadedData(){
      loadedData = [String]()
    }
    
    @objc func populate()
    {
       getValue()
       refresher.endRefreshing()
    }
}


