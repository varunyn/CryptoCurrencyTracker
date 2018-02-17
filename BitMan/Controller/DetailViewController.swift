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

class CubicLineSampleFillFormatter: IFillFormatter {
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
    var symbol = ""
    
    @IBOutlet weak var forName: UILabel!
    
    var NewData = [FetchedData]()
    
    @IBOutlet weak var forUSD: UILabel!
    
    @IBOutlet weak var forBTC: UILabel!
    
    @IBOutlet weak var for1H: UILabel!
    
    @IBOutlet weak var for24H: UILabel!
    
    @IBOutlet weak var for7D: UILabel!
    
    @IBOutlet weak var for24hVol: UILabel!
    
    @IBOutlet weak var coinImage: UIImageView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func segmentedControlTapped(_ sender: Any) {
        switch  segmentedControl.selectedSegmentIndex {
        case 0:
            networkCallForChart(url: "http://coincap.io/history/1day/", details: "24 H")
        case 1 :
            networkCallForChart(url: "http://coincap.io/history/7day/", details: "7 Days")
        case 2:
            networkCallForChart(url: "http://coincap.io/history/30day/",details: "30 Days")
        case 3:
            networkCallForChart(url: "http://coincap.io/history/180day/",details: "180 Days")
        case 4:
            networkCallForChart(url: "http://coincap.io/history/365day/",details: "365 Days")
        default:
            break
        }
    }
    
    
    func didSelect(_ segmentIndex: Int) {
        
    }
    
    var segmentIndex = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        forUSD.text = "$ " + NewData[0].price_usd
        forBTC.text = NewData[0].price_btc
        forName.text = NewData[0].name
        for1H.text = NewData[0].percentage1h + "%"
        for24H.text = NewData[0].percentage
        for7D.text = NewData[0].percentage7d + "%"
        for24hVol.text = NewData[0].vol24h
       coinImage.image =  UIImage(named: "\((NewData[0].symbol).lowercased())")
        
        let change1h = NewData[0].percentage1h
        let change24h = NewData[0].percentage
        let change7d = NewData[0].percentage7d
        
        for1H.textColor = change1h.range(of: "-") != nil ? .red : UIColor(hue: 0.3667, saturation: 0.43, brightness: 0.78, alpha: 1.0)
        for24H.textColor = change24h.range(of: "-") != nil ? .red : UIColor(hue: 0.3667, saturation: 0.43, brightness: 0.78, alpha: 1.0)
        for7D.textColor = change7d.range(of: "-") != nil ? .red : UIColor(hue: 0.3667, saturation: 0.43, brightness: 0.78, alpha: 1.0)
        
        symbol = String(NewData[0].symbol).uppercased()
        
        //HIDE KEYBOARD
        self.hideKeyboardWhenTappedAround()
        
        networkCallForChart(url: "http://coincap.io/history/1day/", details: "24 H")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NewData = [FetchedData]()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func networkCallForChart(url:String,details:String){
        times  = [Double]()
        prices = [Double]()
        
        let urlForCall = url
        
        let finalUrl = urlForCall + symbol
        
        Alamofire.request(finalUrl).responseJSON { response in
            if let json = response.result.value {
                let json = JSON(json)
                for i in 0...json["price"].count {
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
            self.lineChartUpdate(details: details)
        }
    }
    
    func lineChartUpdate(details:String){
        
        var lineChartEntry = [ChartDataEntry]()
        
        for i in 0..<prices.count{
            let value = ChartDataEntry(x: Double(i), y: Double(prices[i]))
            lineChartEntry.append(value)
        }
        
        let line = LineChartDataSet(values : lineChartEntry, label: "")
        lineChart.animate(xAxisDuration: 1.0 , yAxisDuration: 1.0, easingOption: .easeInOutSine)
        
        line.mode = .cubicBezier
        line.drawValuesEnabled = false
        
        lineChart.xAxis.enabled = false
        lineChart.chartDescription?.text = details
        lineChart.leftAxis.drawGridLinesEnabled = false
        lineChart.rightAxis.drawGridLinesEnabled = false
        lineChart.leftAxis.drawLabelsEnabled = false
        lineChart.rightAxis.drawLabelsEnabled = false
        
        line.drawCirclesEnabled = false
        line.lineWidth = 2
        line.circleRadius = 4
        line.colors = [UIColor(hue: 0.0528, saturation: 1, brightness: 0.96, alpha: 1.0)]
        line.setCircleColor(.white)
        //        line.highlightColor = UIColor(hue: 0.3806, saturation: 0.4, brightness: 0.77, alpha: 1.0)
        line.highlightColor = UIColor(hue: 0.0528, saturation: 1, brightness: 0.96, alpha: 1.0) // orange
        //        line.fillColor = UIColor(hue: 0.3806, saturation: 0.4, brightness: 0.77, alpha: 1.0)
        line.fillAlpha = 1
        line.drawHorizontalHighlightIndicatorEnabled = false
        line.fillFormatter = CubicLineSampleFillFormatter()
        line.drawFilledEnabled = true
        
        let gradientColors = [UIColor(hue: 0.0528, saturation: 1, brightness: 0.96, alpha: 1.0).cgColor, UIColor.clear.cgColor] as CFArray // Colors of the gradient
        let colorLocations:[CGFloat] = [1.0, 0.0] // Positioning of the gradient
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) // Gradient Object
        line.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0) // Set the Gradient
        line.drawFilledEnabled = true // Draw the Gradient
        
        let data = LineChartData()
        data.addDataSet(line)
        lineChart.data = data
    }
}
