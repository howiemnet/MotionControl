//
//  Channel.swift
//  MotionControl
//
//  Created by Alan Westbrook on 7/17/15.
//  Copyright (c) 2015 slartibartfist. All rights reserved.
//

import Foundation



struct ChannelDataLive {
    
    var channelState = ChannelState.Offline

    
      var hardwareOnline = false
      var hardwareError = false
      var controlFromUIAllowed = false
      
      // live data
      
      var positionActual = 0.0
      var positionDesired = 0.0
      var velocityCurrent = 0.0
      var positionActualSteps = Int32(0)
      
      // live status
      
      var homeSensorClosed = false
      var externalControlEnabled = false
      var externalControlChannel = 0
      
}

                