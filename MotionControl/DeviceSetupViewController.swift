//
//  DeviceSetupViewController.swift
//  MotionControl
//
//  Created by h on 21/10/2015.
//  Copyright © 2015 slartibartfist. All rights reserved.
//

import Cocoa

class DeviceSetupViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
      
    @IBOutlet weak var tableView: NSTableView!
    
    var channelArray : [ChannelDataPersistent] = []
      
      override func viewDidLoad() {
            super.viewDidLoad()
            // Do view setup here.
            print ("ViewDidLoad - DeviceSetup")
            channelArray = channelLibrary.getAllChannelsPersistentData()
            
      }
      
      @IBAction func OKButton(sender: NSButton) {
            print ("Save button")
            print ("\(channelArray[0].channelInterfaceID)")
            channelLibrary.setAllChannelsPersistentData(channelArray)
            self.dismissViewController(self)
            
      }
      
      @IBAction func CancelButton(sender: NSButton) {
            self.dismissViewController(self)
      }
      // -----------------------------------------------------
      //
      //   Table delegate methods
      //
      // -----------------------------------------------------
      
      // ---- viewForTableColumn ---- //
      
     /* func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
            let persData = channelsUI[channelList[row]]?.channelDataPersistent
            if persData != nil {
                  if persData!.actuatorType == ActuatorType.LensAF {
                        return tableView.makeViewWithIdentifier("LensChannel", owner: self)!
                  } else {
                        return tableView.makeViewWithIdentifier("LinearChannel", owner: self)!
                  }
            }
            return nil
            
      }*/
      
      // ---- objectValueForTableColumn ---- //
      
      func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
            return channelArray[row]
      }
      
      // ---- numberOfRowsInTableView ---- //
      
      func numberOfRowsInTableView(tableView: NSTableView) -> Int {
            return channelArray.count
      }
      
      // ---- heightOfRow ---- //
      
      func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
            return 87
      }


    @IBOutlet weak var addDeviceButton: NSButton!
      
    @IBAction func addDeviceButton(sender: NSButton) {
        let newChannelData = ChannelDataPersistent()
        channelArray.append(newChannelData)
        let theRow = channelArray.count - 1
        tableView.insertRowsAtIndexes(NSIndexSet(index: theRow), withAnimation:NSTableViewAnimationOptions.SlideDown)
        
    }

      
}
