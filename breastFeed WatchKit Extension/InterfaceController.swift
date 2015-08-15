//
//  InterfaceController.swift
//  breastFeed WatchKit Extension
//
//  Created by Brown Magic on 8/4/15.
//  Copyright (c) 2015 codeHatcher. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
  
  let kActiveStateColor = UIColor.greenColor()
  let kPassiveStateColor = UIColor.grayColor()
  // color that designates the last button that was pressed
  let kLastStateColor = UIColor.orangeColor()
  
  @IBOutlet weak var leftTimerInterface: WKInterfaceTimer!
  @IBOutlet weak var rightTimerInterface: WKInterfaceTimer!
  @IBOutlet weak var totalTimerInterface: WKInterfaceTimer!
  @IBOutlet weak var leftButton: WKInterfaceButton!
  @IBOutlet weak var rightButton: WKInterfaceButton!
  @IBOutlet weak var lastFeedDateLabel: WKInterfaceLabel!
  
  var leftTimer:Timer = Timer()
  var rightTimer:Timer = Timer()
  var totalTimer:Timer = Timer()
  // keep track of which button is active
  var buttonState = (left: false, right: false)
  var lastButtonState:(left:Bool, right:Bool)!
  
  var userDefaults = NSUserDefaults.standardUserDefaults()
  
  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    
  }
  
  override func willActivate() {
    // This method is called when watch view controller is about to be visible to user
    super.willActivate()
    lastButtonState =  self.restoreState()
    showLastUsedButton(lastButtonState)
  }
  
  override func didDeactivate() {
    // save the state of the buttons
    self.persistState(lastButtonState)
    // This method is called when watch view controller is no longer visible
    super.didDeactivate()
  }
  @IBAction func onRightButtonTap() {
    // check on the left button
    if buttonState.left {
      // no matter what, disable the left button if it is enabled
      buttonState.left = false
      leftButton.setBackgroundColor(UIColor.darkGrayColor())
      stopTimer(leftTimerInterface, timer: leftTimer)
    }
    // update the right button based on it's current state
    if buttonState.right {
      // if right button is enabled, disable and stop timer and set as last button
      buttonState.right = false
      // this button was last pressed, set right button lastButtonState to remember this and set left to false
      lastButtonState = (false, true)
      showLastUsedButton(lastButtonState)
      // update the timer interface and model
      stopTimer(rightTimerInterface, timer: rightTimer)
      
    } else {
      // if right button is disabled, enable and start timer and remove last button set on the left
      buttonState.right = true
      rightButton.setBackgroundColor(UIColor.greenColor())
      // the left button may have been the last one but it won't be anymore
      leftButton.setBackgroundColor(UIColor.darkGrayColor())
      // update the timer interface and model
      startTimer(rightTimerInterface, timer: rightTimer)
    }
    
    // manage the top timer which stays on if either left/right button is in the on state
    // if either button is on, make sure the timer is on
    println("left: \(buttonState.left) right: \(buttonState.right) isTotalOn: \(totalTimer.on!)")
    if buttonState.left || buttonState.right {
      // only start timer if it is currently off
      if !totalTimer.on! {
        startTimer(totalTimerInterface, timer: totalTimer)
      } else {
        // the timer is already on and should be on, leave it alone
      }
    } else {
      // if both buttons are off, turn off top timer
      stopTimer(totalTimerInterface, timer: totalTimer)
    }
  }
  
  @IBAction func onLeftButtonTap() {
    // check the right button
    if buttonState.right {
      // if its on, turn it off
      buttonState.right = false
      rightButton.setBackgroundColor(UIColor.darkGrayColor())
      stopTimer(rightTimerInterface, timer: rightTimer)
    }
    // check this, left button if it's on
    if buttonState.left {
      // disable left button
      buttonState.left = false
      lastButtonState = (true, false)
      showLastUsedButton(lastButtonState)
      stopTimer(leftTimerInterface, timer: leftTimer)
    } else {
      // enable left button
      buttonState.left = true
      leftButton.setBackgroundColor(UIColor.greenColor())
      rightButton.setBackgroundColor(UIColor.darkGrayColor())
      startTimer(leftTimerInterface, timer: leftTimer)
    }
    // manage the top timer which stays on if either left/right button is in the on state
    // if either button is on, make sure the timer is on
    println("left: \(buttonState.left) right: \(buttonState.right) isTotalOn: \(totalTimer.on!)")
    if buttonState.left || buttonState.right {
      // only start timer if it is currently off
      if !totalTimer.on! {
        startTimer(totalTimerInterface, timer: totalTimer)
      } else {
        // the timer is already on and should be, leave it alone
      }
    } else {
      // if both buttons are off, turn off top timer
      stopTimer(totalTimerInterface, timer: totalTimer)
    }
  }
  @IBAction func onNewButtonTap() {
    // reset data in the timer models
    rightTimer.reset()
    leftTimer.reset()
    
    // reset the timerInterface
    rightTimerInterface.stop()
    rightTimerInterface.setDate(NSDate())
    
    leftTimerInterface.stop()
    leftTimerInterface.setDate(NSDate())
    
    // if any button is active that becomes the new passive state button
    if buttonState.left || buttonState.right {
      lastButtonState = buttonState
    } else {
      // don't do anything because we aren't counting and we want to keep the current passive button state
    }
    
    // reset the button state
    buttonState = (false, false)
    
    // update with the last button state since there should be nothing active at this point
    showLastUsedButton(lastButtonState)
    
    // set now as our last feed
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "MMM-dd h:mm a"
    lastFeedDateLabel.setText(dateFormatter.stringFromDate(NSDate()))
    
    // stop top timer and reset it
    totalTimer.reset()
    //reset the timer interface
    totalTimerInterface.stop()
    totalTimerInterface.setDate(NSDate())
  }
  
  // func checks the button states and update them with the correct color
  func showCurrentButtonState(buttonState:(left:Bool, right:Bool)) {
    if buttonState.left {
      leftButton.setBackgroundColor(kActiveStateColor)
    } else {
      leftButton.setBackgroundColor(kPassiveStateColor)
    }
    if buttonState.right {
      rightButton.setBackgroundColor(kActiveStateColor)
    } else {
      rightButton.setBackgroundColor(kPassiveStateColor)
    }
  }
  
  func showLastUsedButton(lastButtonState:(left:Bool, right:Bool)) {
    // see if any of the last button states are on, if they are go ahead and make the interface reflect that
    if lastButtonState.left {
      leftButton.setBackgroundColor(kLastStateColor)
    } else {
      leftButton.setBackgroundColor(kPassiveStateColor)
    }
    if lastButtonState.right {
      rightButton.setBackgroundColor(kLastStateColor)
    } else {
      rightButton.setBackgroundColor(kPassiveStateColor)
    }
  }
  
  
  func startTimer(timerInterface:WKInterfaceTimer, timer:Timer) {
    // make sure the timer interface has the right info on it
    timerInterface.setDate(timer.date)
    // start the timer interface counting
    timerInterface.start()
    // start the timer model counting
    timer.start()
  }
  
  func stopTimer(timerInterface:WKInterfaceTimer, timer:Timer) {
    // pause the timer label
    timerInterface.stop()
    // pause the timer model counting
    timer.stop()
  }
  
  func persistState(state:(left:Bool, right:Bool)) {
    println("persist the state of the timers")
    // save state of left button
    userDefaults.setObject(state.left, forKey: "buttonStateLeft")
    // save state of right button
    userDefaults.setObject(state.right, forKey: "buttonStateRight")
  }
  
  func restoreState() -> (left:Bool, right:Bool) {
    // object for key will return nil when unset vs boolForKey which will return false
    let leftState = userDefaults.objectForKey("buttonStateLeft") as? Bool
    let rightState = userDefaults.objectForKey("buttonStateRight") as? Bool
    // if the value is nil, this is our first time accessing it, set everything to false
    if leftState == nil || rightState == nil {
      println("first time, will be nil")
      return (false, false);
    } else {
      // use the values in the userDefaults
      println("we already have values")
      return (leftState!, rightState!)
    }
  }
}
