//
//  AllPageController.swift
//  BitMan
//
//  Created by Varun Yadav on 12/5/17.
//  Copyright © 2017 Varun Yadav. All rights reserved.
//

import UIKit
import SwiftyJSON
import Firebase
import NotificationBannerSwift



class AllPageController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchResultsUpdating, UITabBarControllerDelegate, UISearchControllerDelegate {
   
    private var refresher: UIRefreshControl!
    @IBOutlet weak var tableView: UITableView!
    
    var NewData = [FetchedData]()
   
    var filteredArray = [FetchedData]()
    
    var valueSaved = false
    
/*  ---------------------- Start of Search Function  ----------------------  */
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredArray = NewData.filter({( CryptoCurrency : FetchedData) -> Bool in
            return CryptoCurrency.name.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return search.searchBar.text?.isEmpty ?? true
    }
    func isFiltering() -> Bool {
        return search.isActive && !searchBarIsEmpty()
    }
    
    let search = UISearchController(searchResultsController: nil)

/*  ---------------------- End of Search Function  ----------------------  */
    
    
/*  ---------------------- Start of ViewDiDLoad  ----------------------  */
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.tabBarController?.delegate = self
        search.delegate = self

        
        // SearchBar
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Search", style: .plain, target: self, action: #selector(showSearch))

        // TABLEVIEW
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CustomAllPageCell", bundle: nil),forCellReuseIdentifier: "AllPageCell")
        
        getValue()
        
        tableView.setEditing(false, animated: false)
        
//        let longpress = UILongPressGestureRecognizer(target: self, action: Selector("longPressGestureRecognized:"))
//        tableView.addGestureRecognizer(longpress)
        
        // PULL TO REFRESH
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(AllPageController.populate), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        
        //HIDE KEYBOARD
        self.hideKeyboardWhenTappedAround()
       
    }
    
    
    @objc func showSearch () {
        self.navigationItem.searchController = search
        navigationItem.hidesSearchBarWhenScrolling = true
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.isActive = true
    }
    
    
    func willDismissSearchController(_ searchController: UISearchController) {
        self.navigationItem.searchController = nil

    }
    
/*  ---------------------- End of ViewDidLoad  ----------------------  */
    
    override func viewWillAppear(_ animated: Bool) {
       (self.tabBarController as! CustomTabBarController).model = NewData
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {

    tableView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    
//
//    func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
//        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
//        let state = longPress.state
//        var locationInView = longPress.locationInView(tableView)
//        var indexPath = tableView.indexPathForRowAtPoint(locationInView)
//    }
    
    
/*  ---------------------- TableView  ----------------------  */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
        return filteredArray.count
        }
        return NewData.count
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "AllPageCell", for: indexPath) as! CustomAllPageCell
        
        let CryptoCurrency: FetchedData
        if isFiltering() {
            CryptoCurrency = filteredArray[indexPath.row]
        } else {
            CryptoCurrency = NewData[indexPath.row]
        }

        cell.name.text = CryptoCurrency.name
        cell.rank.text = CryptoCurrency.rank
        cell.priceUS.text = CryptoCurrency.price_usd
        
        cell.priceBTC.text = CryptoCurrency.price_btc

        cell.percentLabel.text = NewData[indexPath.row].percentage
        
        let change = cell.percentLabel.text
        
        cell.percentLabel.textColor = change?.range(of: "-") != nil ? .red : .green

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 80.0;//Choose your custom row height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let SecondVC = StoryBoard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        
        let CryptoCurrency: FetchedData
        if isFiltering() {
            CryptoCurrency = filteredArray[indexPath.row]
        } else {
            CryptoCurrency = NewData[indexPath.row]
        }
        
        SecondVC.NewData = [CryptoCurrency]

        self.navigationController?.pushViewController(SecondVC, animated: true)
    }
  
    // SWIPE RIGHT FUNCTION
    
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let CurrencyName = self.NewData[indexPath.row].coinId
        let nameSave : [String:Any] = ["name":CurrencyName]
        
        let banner1 = NotificationBanner(title: "\(CurrencyName)", subtitle: "Added to portfolio", style: .success)
        let banner2 = NotificationBanner(title: "\(CurrencyName)", subtitle: "Already added", style: .warning)
        
        let closeAction = UIContextualAction(style: .normal, title:  "Add to Fav", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            success(true)
    
        guard let userkey = Auth.auth().currentUser?.uid else {return}

            Database.database().reference().child("users")
                .child(userkey)
                .child("Favorite")
                .queryOrdered(byChild: "name")
                .queryEqual(toValue: CurrencyName)
                .observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if snapshot.value as? [String : AnyObject] != nil{
                       
                        banner2.show()
                        
                    } else {
                        
                        Database.database().reference().child("users")
                            .child(userkey)
                            .child("Favorite")
                            .childByAutoId()
                            .setValue(nameSave, withCompletionBlock: { (error, database) in
                                
                        if error != nil {
                            print("Error")
                            }
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
                        
                        })
                         banner1.show()
                    }
                })
            })
       
        closeAction.backgroundColor = .orange
        closeAction.image = UIImage(named: "fav1")
        
        return UISwipeActionsConfiguration(actions: [closeAction])
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.none
    }

    
    // SWIPE LEFT FUNCTION
    
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
//    {
////        let CurrencyName = self.NewData[indexPath.row].coinId
////        let nameSave : [String:Any] = ["name":CurrencyName]
////
////        let banner1 = NotificationBanner(title: "\(CurrencyName)", subtitle: "Added to portfolio", style: .success)
////        let banner2 = NotificationBanner(title: "\(CurrencyName)", subtitle: "Already added", style: .warning)
////
////        let closeAction = UIContextualAction(style: .normal, title:  "Add to Fav", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
////            success(true)
////
////            guard let userkey = Auth.auth().currentUser?.uid else {return}
////
////            Database.database().reference().child("users")
////                .child(userkey)
////                .child("Favorite")
////                .queryOrdered(byChild: "name")
////                .queryEqual(toValue: CurrencyName)
////                .observeSingleEvent(of: .value, with: { (snapshot) in
////
////                    if snapshot.value as? [String : AnyObject] != nil{
////                        banner2.show()
////
////                    } else {
////
////                        Database.database().reference().child("users")
////                            .child(userkey)
////                            .child("Favorite")
////                            .childByAutoId()
////                            .setValue(nameSave, withCompletionBlock: { (error, database) in
////
////                                if error != nil {
////                                    print("Error")
////                                }
////                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
////
////                            })
////                        banner1.show()
////                    }
////
////                })
////        })
////
////
////        closeAction.backgroundColor = .orange
////        closeAction.image = UIImage(named: "fav1")
////        return UISwipeActionsConfiguration(actions: [closeAction])
//        return nil
//
//    }
    
/*  ---------------------- End of TableView ----------------------  */

    
    // FUNCTION FOR NETWORK CALL FROM API
    
    func getValue(){
        
        NewData = [FetchedData]()
        
        let finalUrl = "https://api.coinmarketcap.com/v1/ticker/"
        
        let url = URL.init(string: finalUrl)
        
        do{
            let response = try Data.init(contentsOf: url!)
            
            let json = JSON(data: response)
            for i in 0...49{
                
                let title = String(describing: json[i]["name"])
                let rank = String(describing: json[i]["rank"])
                let USD = String(describing: json[i]["price_usd"])
                let BTC = String(describing: json[i]["price_btc"])
                let ID = String(describing: json[i]["id"])
                let percent = String(describing: json[i]["percent_change_24h"])
                let percent1h = String(describing: json[i]["percent_change_1h"])
                let symbl = String(describing: json[i]["symbol"])
                
                let percent7d = String(describing: json[i]["percent_change_7d"])
                
                let Vol = String(describing: json[i]["24h_volume_usd"])
                
                let c = "%"
                let finalper = "\(percent)" + c
              
                self.NewData.append(FetchedData(name: title,rank: rank, price_usd:USD, price_btc:BTC,percentage:finalper, coinId:ID, percentage1h: percent1h, percentage7d: percent7d, vol24h: Vol, symbol: symbl))
                
            }
        } catch let error {
        
            print(error)
        }
        
        tableView.reloadData()
    }
    
    // FUNCTION TO LOAD WHEN PULL TO REFRESH
    
    @objc func populate()
    {
        getValue()
        tableView.reloadData()
        refresher.endRefreshing()
    }

}



