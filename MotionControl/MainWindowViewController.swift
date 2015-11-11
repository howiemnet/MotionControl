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
     func updateStatus(statusMessage: String)
    var channelsMoving : Int {get set}
    func updateLiveModeButton(state: Bool)
}



class MainWindowViewController: NSViewController, ViewUpdateDelegate {


    @IBOutlet weak var executiveController: ExecutiveController!
    @IBOutlet var channelTableView: ChannelTableView!
    @IBOutlet weak var theTableView: NSTableView!
    @IBOutlet var sequenceController: SequenceController!

    
    
    @IBOutlet weak var messageDisplay: NSTextField!
    @IBOutlet weak var messageSubDisplay: NSTextField!
    
    
  
    @IBAction func homeAllChannels(sender: NSButton) {
        //executiveController.homeAllChannels()
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
    
    
    
    var channelsMoving = 0 {
        didSet {
            if channelsMoving != oldValue {
                messageSubDisplay.integerValue = channelsMoving
                messageSubDisplay.setNeedsDisplay()
            }
        }
    }
    
    

   
    override func viewDidLoad() {
        super.viewDidLoad()
        executiveController.viewController = self
        channelTableView.executiveController = self.executiveController
        sequenceController.executiveController = self.executiveController
        executiveController.scanForDevices()

     }

    override var representedObject: AnyObject? {
        didSet {
            
        }
    }

    func updateStatus(statusMessage: String) {
        messageDisplay.stringValue = statusMessage
        NSLog(statusMessage)
        messageDisplay.setNeedsDisplay()
    
    }
    
    
}

