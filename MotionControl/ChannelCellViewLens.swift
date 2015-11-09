//
//  ChannelCellView.swift
//  MotionControl
//
//  Created by Alan Westbrook on 7/17/15.
//  Copyright (c) 2015 slartibartfist. All rights reserved.
//

import Cocoa

class ChannelCellViewLens: NSTableCellView {
    
    @IBOutlet weak var channelActualPositionSlider: NSSlider!
    @IBOutlet weak var channelActualPositionReadout: NSTextField!
    @IBOutlet weak var channelDesiredPositionSlider: NSSlider!
    @IBOutlet weak var channelDesiredPositionReadout: NSTextField!
    @IBOutlet weak var channelNameField: NSTextField!
    //@IBOutlet weak var offLineSwitch: NSSegmentedCell!
    @IBOutlet weak var channelUnitsActualText: NSTextField!
    @IBOutlet weak var channelUnitsDesiredText: NSTextField!
    
  //  @IBOutlet weak var speedSlider: NSSlider!
  //  @IBOutlet weak var accelSlider: NSSlider!
  //  @IBOutlet weak var speedSliderReadout: NSTextField!
  //  @IBOutlet weak var accelSliderReadout: NSTextField!
    
  //  @IBOutlet weak var speedGraph: NSProgressIndicator!
    @IBOutlet weak var homedIndicator: NSButton!
    
    @IBOutlet weak var trkIndicatorLeft: NSImageView!
    @IBOutlet weak var trkIndicatorRight: NSImageView!
    
 //   @IBOutlet weak var channelDesiredPositionSliderCell: NSSliderCell!
    
    
    @IBOutlet weak var offLineSwitch: NSSegmentedControl!
    
    var oldPositionActual = -99.9
    
    override var objectValue:AnyObject? {
        didSet {
            if let theChannel = objectValue as? Channel {
                
                channelNameField.stringValue = theChannel.channelDataPersistent.channelName
                
                channelActualPositionSlider.maxValue = theChannel.channelDataPersistent.positionMaximum
                channelActualPositionSlider.minValue = theChannel.channelDataPersistent.positionMinimum
                channelDesiredPositionSlider.maxValue = theChannel.channelDataPersistent.positionMaximum
                channelDesiredPositionSlider.minValue = theChannel.channelDataPersistent.positionMinimum
                
                
                channelUnitsActualText.stringValue = theChannel.channelDataPersistent.displayUnits
                channelUnitsDesiredText.stringValue = theChannel.channelDataPersistent.displayUnits
                
              
                
            }
        }
    }
    
    
    
    func updateLiveValues() {
        if let theChannel = objectValue as? Channel {
            if theChannel.channelDataLive.positionActual != oldPositionActual {
                channelActualPositionSlider.doubleValue = theChannel.channelDataLive.positionActual
                channelActualPositionReadout.stringValue = NSString(format: "%.2f", theChannel.channelDataLive.positionActual) as String
                channelDesiredPositionReadout.stringValue = NSString(format: "%.2f", theChannel.channelDataLive.positionDesired) as String
                channelActualPositionSlider.setNeedsDisplay()
                oldPositionActual = theChannel.channelDataLive.positionActual
            }
            
               // speedGraph.doubleValue = 100.0 * (abs(theChannel.channelDataLive.velocityCurrent) / (theChannel.channelDataPersistent.absoluteMaximumSpeed))
                //speedGraph.setNeedsDisplay()
                /*
                trkIndicatorLeft.image = (value.velocityCurrent >= 0.0 ) ? NSImage(named: "trkIndicatorOFFGreen"): NSImage(named: "trkIndicatorOnGreen")
                trkIndicatorLeft.setNeedsDisplay()
                trkIndicatorRight.image = (value.velocityCurrent <= 0.0 ) ? NSImage(named: "trkIndicatorOFFGreen"): NSImage(named: "trkIndicatorOnGreen")
                trkIndicatorRight.setNeedsDisplay()
                */
                //oldVelocity = value.velocityCurrent
            
        }
    }

    
    
    /*
    
    @IBAction func quickJumpButton(sender: NSButton) {
        if let targetData = objectValue as? Channel {
            
            switch (sender.tag) {
            case 0:
                targetData.positionDesired = channelDesiredPositionSlider.minValue
                break
            case 1:
                targetData.positionDesired = channelDesiredPositionSlider.minValue + (0.25 * (channelDesiredPositionSlider.maxValue - channelDesiredPositionSlider.minValue))
                break
            case 2:
                targetData.positionDesired = channelDesiredPositionSlider.minValue + (0.5 * (channelDesiredPositionSlider.maxValue - channelDesiredPositionSlider.minValue))
                break
            case 3:
                targetData.positionDesired = channelDesiredPositionSlider.minValue + (0.75 * (channelDesiredPositionSlider.maxValue - channelDesiredPositionSlider.minValue))
                break
            case 4:
                targetData.positionDesired = channelDesiredPositionSlider.maxValue
                break
            default:
                break
            }
        }
    }
    */
    
    @IBAction func channelDesiredPositionSliderMoved(sender: NSSlider) {
        let theValue = sender.doubleValue
        if let targetData = objectValue as? Channel {
            
            // need to send this as a request to ChannelHandler rather than just changing the model
            
//            targetData.positionDesired = theValue
 //           channelDesiredPositionReadout.stringValue = NSString(format: "%.2f", theValue) as String
        }
    }
    
    @IBAction func channelOnlineSwitch(sender: NSSegmentedControl) {
         if let channel = objectValue as? Channel {
            let newState = (sender.selectedSegment == 1)
   //         if newState != channel.online {
   //             channel.online = newState
   //             channel.executiveController.channelOnlineChange(channel)
   //         }
        }
    }
    
   
    
    @IBAction func homeButtonPressed(sender: NSButton) {
        if let chan = objectValue as? Channel {
     //       chan.executiveController.homeOneChannel(chan)
        }
    }
    
    
    
}
