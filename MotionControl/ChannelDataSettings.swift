//
//  ChannelDataSettings.swift
//  
//
//  Created by h on 16/10/2015.
//
//

import Foundation

enum ChannelState {
      case Offline
    case QueryingInitialState
      case HandControl
      case Idle
      case Moving
      case PlayingSequence
      case Homing
    case Uninitialised
}


struct ChannelDataSettings {
      

  
    var maximumSpeed = 0.0
    var maximumAcceleration = 0.0
    
    var simulationMode = false
    var channelMute = false

}