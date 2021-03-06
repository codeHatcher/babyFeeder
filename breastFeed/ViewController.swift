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

  @IBOutlet weak var chartView: LineChartView!
  
  let kActiveStateColor = UIColor(red:0.83, green:0.309, blue:0.315, alpha:1)
  let kDarkGrey = UIColor(red:0.152, green:0.152, blue:0.152, alpha:1)
  
  let realm = Realm()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    // register notification when application becomes active from background state
    NSNotificationCenter.defaultCenter().addObserver(
      self,
      selector: "applicationDidBecomeActive:",
      name: UIApplicationDidBecomeActiveNotification,
      object: nil)
    // get data from db
    let feedData = realm.objects(FeedData)
    // add bar chart data
    setChart(feedData: feedData)
    
    // set background to dark grey
    self.view.backgroundColor = kDarkGrey
    
  }
  func applicationDidBecomeActive(notification: NSNotification) {
    // do something
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
    var leftYAxis = chartView.getAxis(ChartYAxis.AxisDependency.Left)
    var rightYAxis = chartView.getAxis(ChartYAxis.AxisDependency.Right)
    var xAxis = chartView.xAxis
    
    leftYAxis.enabled = false
    leftYAxis.drawGridLinesEnabled = false
    leftYAxis.drawAxisLineEnabled = false
    rightYAxis.enabled = false
    rightYAxis.drawGridLinesEnabled = false
    rightYAxis.drawAxisLineEnabled = false
    xAxis.drawGridLinesEnabled = false
    xAxis.drawAxisLineEnabled = false
    xAxis.labelTextColor = UIColor.whiteColor()
    xAxis.labelFont = UIFont.systemFontOfSize(16)
		xAxis.avoidFirstLastClippingEnabled = true
    
    chartView.noDataText = "Start using the watch app and see your data here!"
    chartView.descriptionText = ""
    chartView.backgroundColor = kDarkGrey
    chartView.drawGridBackgroundEnabled = false
    chartView.gridBackgroundColor = UIColor.whiteColor()
    
    var dataEntries:[ChartDataEntry] = []
    for i in 0..<feedData.count {
      let dataEntry = ChartDataEntry(value: feedData[i].durationInSeconds, xIndex: i)
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
    
    let chartDataSet = LineChartDataSet(yVals: dataEntries, label: "Time Fed")
    // settings for this specific data set
    chartDataSet.drawCubicEnabled = true
    chartDataSet.drawFilledEnabled = true
//    chartDataSet.drawValuesEnabled = true
    chartDataSet.lineWidth = 5.0;
    chartDataSet.circleRadius = 10.0;
    chartDataSet.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1.0)
    chartDataSet.setColor(kActiveStateColor)
    chartDataSet.fillColor = kActiveStateColor
    chartDataSet.fillAlpha = 100
    chartDataSet.cubicIntensity = 0.2
    chartDataSet.circleColors = [kActiveStateColor]
    chartDataSet.valueTextColor = UIColor.whiteColor()
    chartDataSet.valueFont = UIFont.systemFontOfSize(13)
    // remove legend
    chartView.legend.enabled = false
    // format the duration data
    chartDataSet.valueFormatter = FeedDurationFormatter.sharedInstance
    
    let chartData = LineChartData(xVals: dataX, dataSet: chartDataSet)
    chartView.data = chartData
    
    // only afer setting the data can we tell the max data to show
    chartView.setVisibleXRangeMaximum(4)
//		chartView.setVisibleXRangeMinimum(1)
    // try to align the initial view to prevent as much skipping
    chartView.moveViewToX(dataX.count - 1)
		//chartView.centerViewTo(xIndex: dataX.count-1, yValue: dataEntries[dataX.count-1].value, axis: chartView.xAxis)
		// make sure there is padding so that points near the edge aren't cut off
		chartView.setExtraOffsets(left: 30, top: 0, right: 30, bottom: 0)
    chartView.dragEnabled = true
		chartView.setDragOffsetX(0)
    
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

