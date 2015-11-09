//
//  ChannelTableView.swift
//  MotionControl
//
//  Created by h on 28/07/2015.
//  Copyright © 2015 slartibartfist. All rights reserved.
//

import Cocoa

class ChannelTableView : NSObject, NSTableViewDelegate, NSTableViewDataSource {
    
    // ---- Channel information ---- //
    // 
    //  channelList is a list of channel IDs in the
    //  order they appear in the Table
    //
    
    var channelList = [Int]()
    
    //
    //  channelsUI is the data for the channels,
    //  stored against the channel IDs.
    //
    //  So to get the data for the second row of
    //  the table, get channelsUI[channelList[2]].
    //  (which will return an optional)
    //
    
    var channelsUI = [Int : ChannelUI]()

    
    // ---- OUTLETS ---- //
    @IBOutlet weak var executiveController: ExecutiveController!
    @IBOutlet weak var channelTableView: NSTableView!
    
    // -----------------------------------------------------
    //
    //   Init
    //
    // -----------------------------------------------------

    override init() {
        super.init()
        print("channeltableview init")
    }

    // -----------------------------------------------------
    //
    //   Table delegate methods
    //
    // -----------------------------------------------------

    // ---- viewForTableColumn ---- //
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let persData = channelsUI[channelList[row]]?.channelDataPersistent
        if persData != nil {
          //  if persData!.actuatorType == ActuatorType.LensAF {
          //      return tableView.makeViewWithIdentifier("LensChannel", owner: self)!
          //  } else {
               return tableView.makeViewWithIdentifier("LinearChannel", owner: self)!
          //  }
        }
        return nil

    }
   
    // ---- objectValueForTableColumn ---- //
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return channelsUI[channelList[row]] ?? nil
    }
    
    // ---- numberOfRowsInTableView ---- //
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return channelList.count ?? 0
    }
    
    // ---- heightOfRow ---- //

    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
     //   if (channelsUI[channelList[row]])?.channelDataPersistent.actuatorType == .LensAF {
     //       return 60.0
     //   } else {
            return 97.0
     //   }
    }
    
    // -----------------------------------------------------
    //
    //   Update methods (called by ExecutiveController)
    //
    // -----------------------------------------------------

    
    func updateLiveDataForChannel(channelID: Int, liveData: ChannelDataLive) {
        
        // make sure we have the channel requested in the table
        let theRow = channelList.indexOf(channelID)
        if theRow != nil {
            
            channelsUI[channelID]?.channelDataLive = liveData
            
            let theView = channelTableView.viewAtColumn(0, row: theRow!, makeIfNecessary: false)
            if let theCell = theView as? ChannelCellView {
                theCell.updateLiveValues()
            }
        }
    }


    func updateAllDataForChannel(channelID: Int, liveData: ChannelDataLive) {
        let theRow = channelList.indexOf(channelID)
        if theRow != nil {
            
            channelsUI[channelID]?.channelDataLive = liveData
            channelTableView!.reloadDataForRowIndexes(NSIndexSet(index: theRow!), columnIndexes: NSIndexSet(index: 0))
        }
    }

    // -----------------------------------------------------
    //
    //   Add and remove channels...
    //
    // -----------------------------------------------------

    func addNewChannel(persistent: ChannelDataPersistent, settings: ChannelDataSettings, live: ChannelDataLive) {
        if channelList.indexOf(persistent.channelInterfaceID) != nil {
            print ("ERROR: trying to add an already existing channel ID to the table")
            return
        }
        // create a new channelUI object and populate it
        
        let channelUI = ChannelUI(handler: executiveController, persist: persistent, settings: settings, live: live)
        
        // add it to our display list
        
        channelList.append(channelUI.channelDataPersistent.channelInterfaceID)
        channelsUI[channelUI.channelDataPersistent.channelInterfaceID] = channelUI
        let newChannelNumber = channelList.count - 1
        
        // insert it into the table with animation
        
        channelTableView.insertRowsAtIndexes(NSIndexSet(index: newChannelNumber), withAnimation: NSTableViewAnimationOptions.SlideDown)
        
    }

    
    
    func removeChannelWithID(channelID: Int) {
        let theRow = channelList.indexOf(channelID)
        if theRow != nil {
            // remove from the table
            channelList.removeAtIndex(theRow!)
            channelTableView.removeRowsAtIndexes(NSIndexSet(index: theRow!), withAnimation: NSTableViewAnimationOptions.SlideUp)
            // and remove from our channelUI data array:
            channelsUI[channelID] = nil
        }
        
    }


}