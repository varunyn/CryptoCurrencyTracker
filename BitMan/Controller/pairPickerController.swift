//
//  pariPickerController.swift
//  BitMan
//
//  Created by Varun Yadav on 2/12/18.
//  Copyright © 2018 Varun Yadav. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class pairPickerController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var pairs = [String]()
    var routes = [String]()
    var id = [Any]()
    var pairName = ""
    
    var delegate: pairPickControllerDeletegate?
    
    var tradingPairURL = "https://api.cryptowat.ch/markets/"
    var exchangeID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let finalURL = tradingPairURL + exchangeID
        
        Alamofire.request(finalURL).responseJSON { response in
            if let json = response.result.value {
                let json = JSON(json)
                
                for i in 0...json["result"].count {
                    let id  = json["result"][i]["id"]
                    let route = json["result"][i]["route"]
                    let pair = json["result"][i]["pair"]
                    
                    if id != JSON.null {
                        self.id.append(id)
                        self.routes.append(String(describing: route))
                        self.pairs.append(String(describing: pair))
                    }
                }
            }
            self.tableView.reloadData()
            print(self.pairs.count)
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pairs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pairPickerCell") as! pairPickerCell
        cell.nameLabel.text = pairs[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pairName = pairs[indexPath.row]
        delegate?.pairName(name: pairName)
        self.navigationController?.popViewController(animated: true)
    }
    
}
