//
//  MainWindowViewController
//  MotionControl
//
//  Created by Alan Westbrook on 7/17/15.
//  Copyright (c) 2015 slartibartfist. All rights reserved.
//

import Cocoa
import Foundation
import Quartz

protocol ViewUpdateDelegate : class {
   // func updateUIForChannel(channel: Int)
   // func updateAllUIForChannel(channel: Int)
    
    func updateExecutiveControls()
    func updateStatus(statusMessage: String)
    var channelsMoving : Int {get set}
    func updateLiveModeButton(state: Bool)
}



class MainWindowViewController: NSViewController, ViewUpdateDelegate {

    //var executiveController = ExecutiveController()

    @IBOutlet var channelTableView: ChannelTableView!
    @IBOutlet weak var masterOnlineSwitch: NSSegmentedControl!
    @IBOutlet weak var motionStateIndicator: NSSegmentedControl!
    @IBOutlet weak var theTableView: NSTableView!
    @IBOutlet var sequenceController: SequenceController!

    @IBOutlet weak var messageDisplay: NSTextField!
    @IBOutlet weak var messageSubDisplay: NSTextField!
    
    @IBOutlet var executiveController: ExecutiveController!
    
    @IBOutlet weak var sequencePlayButton: NSButton!
    @IBAction func sequencePlayButton(sender: NSButton) {
        executiveController.startSequencePlayback()
        print ("PLAY HIT!")
    }
  
    @IBAction func homeAllChannels(sender: NSButton) {
        executiveController.homeAllChannels()
    }
    @IBAction func testButton(sender: NSButton) {
        
        executiveController.scanForDevices()
         
    }
    
    
    
    @IBOutlet weak var liveModeButton: NSButton!
    
    
    @IBAction func liveModeButton(sender: NSButton) {
        if (sender.state == NSOnState) {
            executiveController.liveModeEnable()
        } else {
            executiveController.liveModeDisable()
        }
    }
    
    func updateLiveModeButton(state: Bool) {
        if state {
            liveModeButton.state = NSOnState
        } else {
            liveModeButton.state = NSOffState
        }
    }
    
    
    
    //var oldChannelsMoving = 99
    var channelsMoving = 0 {
        didSet {
            if channelsMoving != oldValue {
                messageSubDisplay.integerValue = channelsMoving
                messageSubDisplay.setNeedsDisplay()
            }
        }
    }
    
    

    @IBAction func masterOnlineSwitchChanged(sender: NSSegmentedControl) {
        executiveController.masterOnlineState = (sender.selectedSegment == 1)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
     //   self.view.wantsLayer = true
     //   self.view.layer?.backgroundColor = NSColor(calibratedHue: 0.0, saturation: 0.0, brightness: 0.5, alpha: 1.0)
        executiveController.viewController = self
        //sequencerTableView.sequenceController = self.sequenceController
        channelTableView.executiveController = self.executiveController
        sequenceController.executiveController = self.executiveController
      // masterOnlineSwitch.selectSegmentWithTag((executiveController.masterOnlineState) ? 1 : 0)
        executiveController.scanForDevices()

     }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
            
        }
    }

    /*func updateUIForChannel(channel: Int) {
        channelTableView.updateLiveDataForChannel(channel)
       /* if channel==1 {
        dispatch_async(dispatch_get_main_queue()) {
            self.theTableView.reloadData() //   .reloadDataForRowIndexes(NSIndexSet(index: channel), columnIndexes: NSIndexSet(index:0))
        }
    }*/
    }
    
    
    func updateAllUIForChannel(channel: Int) {
        channelTableView.updateAllUIForChannel(channel)
        /* if channel==1 {
        dispatch_async(dispatch_get_main_queue()) {
        self.theTableView.reloadData() //   .reloadDataForRowIndexes(NSIndexSet(index: channel), columnIndexes: NSIndexSet(index:0))
        }
        }*/
    }

    */
    func updateStatus(statusMessage: String) {
        messageDisplay.stringValue = statusMessage
        NSLog(statusMessage)
        messageDisplay.setNeedsDisplay()
    
    }
    
    func updateExecutiveControls() {
/*        dispatch_async(dispatch_get_main_queue()) {
        if self.executiveController.executiveStateData.motionState == .Idle {
            self.motionStateIndicator.selectSegmentWithTag(0)
        } else {
            self.motionStateIndicator.selectSegmentWithTag(1)
            
        }
        
        self.sequencePlayButton.enabled = self.executiveController.executiveStateData.playbackPossible
        
        }
*/    }
    
}

