//
//  ViewController.swift
//  breastFeed
//
//  Created by Brown Magic on 8/4/15.
//  Copyright (c) 2015 codeHatcher. All rights reserved.
//

import UIKit
import Charts
import RealmSwift

class ViewController: UIViewController {

  @IBOutlet weak var barChartView: BarChartView!
  
  let realm = Realm()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    // get data from db
    let feedData = realm.objects(FeedData)
    // add bar chart data
    setChart(feedData: feedData)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  func setChart(#feedData:Results<FeedData>) {
    var leftYAxis = barChartView.getAxis(ChartYAxis.AxisDependency.Left)
    var rightYAxis = barChartView.getAxis(ChartYAxis.AxisDependency.Right)
    // max values to show on the chart at any time
    let maxValues:CGFloat = 4
    
    leftYAxis.enabled = false
    rightYAxis.enabled = false
    barChartView.noDataText = "Start using the watch app and see your data here!"
    barChartView.descriptionText = "Your baby feed timings"
    barChartView.backgroundColor = UIColor.whiteColor()
    barChartView.gridBackgroundColor = UIColor.whiteColor()
    
    var dataEntries:[BarChartDataEntry] = []
    for i in 0..<feedData.count {
      let dataEntry = BarChartDataEntry(value: feedData[i].durationInSeconds, xIndex: i)
      dataEntries.append(dataEntry)
    }
    // date formatter for X axis
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
    dateFormatter.timeStyle = .ShortStyle
    
    var dataX:[String] = []
    for i in 0..<feedData.count {
      // have data entry be a date string from the end date passed in
      let dataEntry = dateFormatter.stringFromDate(feedData[i].endTime)
      dataX.append(dataEntry)
    }
    
    let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "Time Fed")
    // remove legend
    barChartView.legend.enabled = false
    // format the duration data
    chartDataSet.valueFormatter = FeedDurationFormatter.sharedInstance
    
    let chartData = BarChartData(xVals: dataX, dataSet: chartDataSet)
    barChartView.data = chartData
    
    // only afer setting the data can we tell the max data to show
    barChartView.setVisibleXRangeMaximum(maxValues)
    // try to align the initial view to prevent as much skipping
    barChartView.moveViewToX((dataX.count - 1) - (Int(maxValues)))
    barChartView.dragEnabled = true
    
  }
  
  class FeedDurationFormatter: NSNumberFormatter {
    required init(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
    }
    
    override init() {
      super.init()
      self.locale = NSLocale.currentLocale()
    }
    
    override func stringFromNumber(duration: NSNumber) -> String? {
      let duration = duration.floatValue
      let minutes = floor(duration / 60)
      let seconds = duration % 60.0
      
      // time string, we don't want the decimals
      let timeString = String(format: "%01dm %01ds", Int(minutes), Int(seconds))
      
      return timeString
    }
    
    // Swift 1.2 or above
    static let sharedInstance = FeedDurationFormatter()
  }

}

