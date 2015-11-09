//
//  ExecutiveStateData.swift
//  MotionControl
//
//  Created by h on 21/07/2015.
//  Copyright © 2015 slartibartfist. All rights reserved.
//

import Foundation

class ExecutiveStateData {
    
    enum AppState {
        case Manual
        case PlayingSequence
    }
    
    enum MotionState {
        case Moving
        case Idle
    }
    
    enum SequenceState {
        case NoViableSequence
        case SequencePlaybackPossible
    }
    
    var appState: AppState = .Manual
    var motionState: MotionState = .Idle
    var sequenceViable = false
    var playbackPossible = false
    
}

class ChannelPositionSet {
    var positions = [Double]()
}