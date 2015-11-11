//
//  Channel.swift
//  MotionControl
//
//  Created by Alan Westbrook on 7/17/15.
//  Copyright (c) 2015 slartibartfist. All rights reserved.
//

import Foundation




struct ChannelPositionDict {
    // dictionary of ID : Position
    var channelPositions : [Int:Double]
}




class Channel {
      var trajectoryHandler: TrajectoryHandler! = nil
    let channelHandler: ChannelHandler
    let channelDataPersistent: ChannelDataPersistent
    var channelDataSettings: ChannelDataSettings
    var channelDataLive: ChannelDataLive
    var dataUpdated = false
    
    
    init(handler: ChannelHandler, persist: ChannelDataPersistent, settings: ChannelDataSettings, live: ChannelDataLive) {
        channelHandler = handler
        channelDataPersistent = persist
        channelDataSettings = settings
        channelDataLive = live
        trajectoryHandler = TrajectoryHandler(chan: self, handler: channelHandler)
    }
    
}


class ChannelUI {
    let channelHandler: ExecutiveController
    let channelDataPersistent: ChannelDataPersistent
    var channelDataSettings: ChannelDataSettings
    var channelDataLive: ChannelDataLive
    
    init(handler: ExecutiveController, persist: ChannelDataPersistent, settings: ChannelDataSettings, live: ChannelDataLive) {
        channelHandler = handler
        channelDataPersistent = persist
        channelDataSettings = settings
        channelDataLive = live
    }
    
}
