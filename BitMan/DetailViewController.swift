//
//  DetailViewController.swift
//  BitMan
//
//  Created by Varun Yadav on 12/12/17.
//  Copyright © 2017 Varun Yadav. All rights reserved.
//

import UIKit
import Charts
import SwiftyJSON
import Alamofire

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

private class CubicLineSampleFillFormatter: IFillFormatter {
    func getFillLinePosition(dataSet: ILineChartDataSet, dataProvider: LineChartDataProvider) -> CGFloat {
        return -10
    }
}


class DetailViewController: UIViewController {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
    @IBOutlet weak var lineChart: LineChartView!
    
    
    
    var times  = [Double]()
    var prices = [Double]()
    
    @IBOutlet weak var forName: UILabel!
    
    var NewData = [FetchedData]()
    var c = ""
    
    @IBOutlet weak var forUSD: UILabel!
    
    @IBOutlet weak var forBTC: UILabel!
    
    @IBOutlet weak var for1H: UILabel!
    
    @IBOutlet weak var for24H: UILabel!
    
    @IBOutlet weak var for7D: UILabel!
    
    @IBOutlet weak var for24hVol: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        forUSD.text = NewData[0].price_usd
        forBTC.text = NewData[0].price_btc
        forName.text = NewData[0].name
        for1H.text = NewData[0].percentage1h + "%"
        for24H.text = NewData[0].percentage
        for7D.text = NewData[0].percentage7d + "%"
        for24hVol.text = NewData[0].vol24h
        
        let change1h = NewData[0].percentage1h
        let change24h = NewData[0].percentage
        let change7d = NewData[0].percentage7d
        
        for1H.textColor = change1h.range(of: "-") != nil ? .red : .green
        for24H.textColor = change24h.range(of: "-") != nil ? .red : .green
        for7D.textColor = change7d.range(of: "-") != nil ? .red : .green
        
        //HIDE KEYBOARD
        self.hideKeyboardWhenTappedAround()
        
        let symbol = String(NewData[0].symbol).uppercased()
        times  = [Double]()
        prices = [Double]()
        
        let finalUrl = "http://coincap.io/history/1day/" + "\(symbol)"
        
        Alamofire.request(finalUrl).responseJSON { response in
            if let json = response.result.value {
                let json = JSON(json)
                for i in 0...json.count {
                    let time  = json["price"][i][0].double
                    let priceInUsd = json["price"][i][1].double
                    
                    if time != nil {
                        self.times.append(time!)
                    }
                    if priceInUsd != nil {
                        self.prices.append(priceInUsd!)
                    }
                }
            }
            self.lineChartUpdate()
        }
        
        //        let url = URL.init(string: finalUrl)
        //        let networkResponse = URLSession.shared.dataTask(with: url!){ [weak self] ( data, response, error) in
        //             guard let data = data else { return }
        //        do{
        //            let response = try Data.init(contentsOf: url!)
        //
        //            let json = JSON(data: response)
        //            for i in 0...10{
        //
        //                let time  = json["price"][i][0].int
        //                let priceInUsd = json["price"][i][1].int
        //
        //                self?.times.append(time!)
        //                self?.prices.append(priceInUsd!)
        //
        //            }
        //        } catch let error {
        //
        //            print(error)
        //        }
        //        }
        //        networkResponse.resume()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NewData = [FetchedData]()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func convertValue (usd: Double, coin: Double) {
        
    }
    
    func lineChartUpdate(){
        
        var lineChartEntry = [ChartDataEntry]()
        
        for i in 0..<prices.count{
            let value = ChartDataEntry(x: Double(i), y: Double(prices[i]))
            lineChartEntry.append(value)
        }
        
        let line = LineChartDataSet(values : lineChartEntry, label: "prices")
        line.mode = .cubicBezier
        line.drawValuesEnabled = false
        lineChart.xAxis.enabled = false
        
        lineChart.leftAxis.drawGridLinesEnabled = false
        lineChart.rightAxis.drawGridLinesEnabled = false
        
        lineChart.leftAxis.drawLabelsEnabled = false
        lineChart.rightAxis.drawLabelsEnabled = false
        line.drawCirclesEnabled = false
        line.lineWidth = 1.8
        
        line.circleRadius = 4
        line.setCircleColor(.white)
        line.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
        line.fillColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
        line.fillAlpha = 1
        line.drawHorizontalHighlightIndicatorEnabled = false
        line.fillFormatter = CubicLineSampleFillFormatter()
        line.drawFilledEnabled = true
        
        let data = LineChartData()
        data.addDataSet(line)
        lineChart.data = data
    }
    
}
