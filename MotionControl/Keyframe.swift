//
//  Keyframe.swift
//  MotionControl
//
//  Created by h on 27/07/2015.
//  Copyright © 2015 slartibartfist. All rights reserved.
//

import Foundation


class Keyframe {

    var sequenceController: SequenceController
    
    init (seqCnt: SequenceController) {
        sequenceController = seqCnt
        subjectPosition = Position(x: 0.0, y: 0.0)
    }
    
    enum EasingType {
        case None
        case Linear
        case Sin
    }
    
    var channelPositions = [Int:Double]()
    
    var cueNum = 0
    var cueName = "asdf"
    
    var duration = 0.0
    var distance = 0.0
    
    var dominantChannel = 0
    
    // easing:
    var useSameEaseForInAndOut = false
    
    var easeInType = EasingType.Linear
    var easeOutType = EasingType.Linear
    var easeInDuration = 0.0
    var easeOutDuration = 0.0
    
    // triangulation:
    var subjectTriangulated = false
    var triangulationEnabled = false
    var subjectPosition : Position
    var subjectDistanceAtStart = 0.0
    var subjectDistanceAtEnd = 0.0
    
}