//
//  Trajectory Handler
//
//  MotionControl
//
//  Created by h on 22/07/2015.
//  Copyright © 2015 slartibartfist. All rights reserved.
//

import Foundation

class TrajectoryHandler {
    
    enum TrajectoryState : String {
        case EmergencyStop = "Emergency stop!"
        case StoppedEmergency = "Stopped!"
        case StoppedAtTarget = "Stopped at target"
        case WrongDirection = "Wrong direction"
        case Overshoot = "Overshoot"
        case InStoppingBand = "In stopping band"
        case Coasting = "Coasting"
        case CoastingMax = "Coasting at max speed"
        case SlowingFromOverspeed = "Slowing from over speed"
        case Accelerating = "Accelerating"
        case FinalFrame = "In final frame"
        case BlenderPlayback = "Blender playback"
    }

    
    
    // ----------------------------------
    //
    //   Keep a local copy of live data,
    //   update it and pass it back
    //
    // ----------------------------------
    
    var channel : Channel!
    
    var liveData : ChannelDataLive
    var positionDesired = Double(0.0)
    var oldTargetPosition = 0.0
    var currentState = TrajectoryState.StoppedAtTarget
    var finalDecelleration = 0.0
    var playbackStream = [Double]()
    var currentFrame = 0
    
    // ----------------------------------
    //
    //   State stuff
    //
    // ----------------------------------
    
    
    func setState(state: TrajectoryState) {
        if state != currentState {
            print ("Trajectory state: \(state.rawValue)")
            currentState = state
        }
    }
    
    
    
    init(chan: Channel) {
        channel = chan
        liveData = channel.channelDataLive
    }
    
    
    func preparePlaybackStream(data: [Double]) {
        playbackStream = data
        currentFrame = 0
    }
    
    func startPlayback() {
        if (playbackStream.count > 0) {
            currentState = .BlenderPlayback
            channel.channelHandler.trajectoryStarted(channel.channelDataPersistent.channelInterfaceID)
        }
    }
    
    // --------------------------------------
    //
    //   Calls from outside
    //
    // --------------------------------------

    
    
    // -------- NEW DESIRED POSITION ---- //
    
    func setNewPositionDesired(value: Double) {
        // dirty the trajectory if necessary
       // if positionDesired != value {
            positionDesired = value
            liveData.positionDesired = positionDesired
            finalDecel = false
            if currentState == .StoppedAtTarget {
                currentState = .Accelerating
                liveData = getNextFrame()
                channel.channelHandler.trajectoryStarted(channel.channelDataPersistent.channelInterfaceID)
            }
        //}
    }
    
    
    // -------- CHANGE SPEED / ACCEL ---- //

    func setNewSpeedAndAccel(mSpeed: Double, mAccel: Double) {
        channel.channelDataSettings.maximumSpeed = mSpeed
        channel.channelDataSettings.maximumAcceleration = mAccel
        finalDecel = false
    }

    
    func stopNow() {
        currentState = .EmergencyStop
        
        
    }
    
    func disableTrajectory() {
        currentState = TrajectoryState.StoppedAtTarget
        finalDecel = false
    }
    
    
    
    // ----------------------------------
    //
    //   getNextFrame
    //
    //   This switches depending on the
    //   current motion state/mode
    //
    // ----------------------------------
    
    
    
    func getNextFrame() -> ChannelDataLive {
        //
        // switch here
        
        //if (channel.channelDataPersistent.actuatorType == .LensAF) {
        //    liveData.positionActual = liveData.positionDesired
        //    liveData.velocityCurrent = 0.0
            //return
        //}
        
        //liveData.positionDesired = positionDesired
        
        switch currentState {
        case .EmergencyStop:
            updateLiveDataForEmergencyStop()
            break
        case .StoppedAtTarget:
            
            channel.channelHandler.trajectoryFinished(channel.channelDataPersistent.channelInterfaceID)
        case .BlenderPlayback:
            updateLiveDataFromBlenderFile()
        default:
            updateLiveDataForManualMove()
        }
        scaleForActuator()
        
        return liveData
    }
    
    
    
    
    
    
    func scaleForActuator() {
        if (channel.channelDataPersistent.actuatorType == .LensAF) {
            liveData.positionActualSteps = Int32(LensHandler().getLensStepsFromDistance(liveData.positionActual))

        } else {
            liveData.positionActualSteps = Int32(channel.channelDataPersistent.scale * liveData.positionActual)
        }

    }
    


    
    // -----------------------------------------------------------------------
    //
    //      updateLiveDataForEmergencyStop
    //
    //
    // -----------------------------------------------------------------------

    func updateLiveDataFromBlenderFile() {
        let oldPos = liveData.positionActual
        liveData.positionActual = playbackStream[currentFrame]
        liveData.positionDesired = liveData.positionActual
        liveData.velocityCurrent = liveData.positionActual - oldPos
        currentFrame += 1
        if currentFrame == playbackStream.count {
            //liveData.positionDesired = liveData.positionActual
            liveData.velocityCurrent = 0.0
            currentState = .StoppedAtTarget
            
        }
    }
    
    
    // -----------------------------------------------------------------------
    //
    //      updateLiveDataForEmergencyStop
    //
    //
    // -----------------------------------------------------------------------

    func updateLiveDataForEmergencyStop() {
        var speed = abs(liveData.velocityCurrent)
        if speed == 0 {
            currentState = .StoppedAtTarget
        } else {
           speed = max(0.0, speed-channel.channelDataSettings.maximumAcceleration)
            if liveData.velocityCurrent > 0.0 {
                liveData.velocityCurrent = speed
            } else {
                liveData.velocityCurrent = -speed
            }
            liveData.positionActual += liveData.velocityCurrent
            liveData.positionDesired = liveData.positionDesired
            positionDesired = liveData.positionDesired
        
        }
    }
    
    
    
    
    
    
    // -----------------------------------------------------------------------
    //
    //      MANUAL CONTROL
    //
    //
    // -----------------------------------------------------------------------
    
    
    
    
    var finalDecel = false
    var finalDecelRate = 0.0
    var finalDecelFrames = 0.0
    
    func updateLiveDataForManualMove() {
        
        
        
        // ---------------------------------
        //    Calculate some useful stuff
        // ---------------------------------
        
        let currentSpeed = abs(liveData.velocityCurrent)
        let distanceToTarget = abs(liveData.positionActual - liveData.positionDesired)
        let targetDirection = (liveData.positionDesired >= liveData.positionActual)
        let currentDirection = (liveData.velocityCurrent >= 0.0)
        
        if liveData.positionDesired != oldTargetPosition {
            // reset some stuff here
        }
        
        
        // ---------------------------------
        //    Are we stopped and stable?
        // ---------------------------------
        
        if (distanceToTarget == 0.0) && (currentSpeed <= channel.channelDataSettings.maximumAcceleration) {
            
            // ---------------------------------
            //    Yes, so stop.
            // ---------------------------------
            
            liveData.velocityCurrent = 0.0
            setState(.StoppedAtTarget)
            
        } else {
            
            
            
            
            
            // ------------------------------------------
            //    Not at target - or passing target in the wrong
            //    direction:
            //    Are we going to need to turn round?
            // ------------------------------------------
            
            if (currentSpeed > 0.0) && ((currentDirection != targetDirection) || (distanceToTarget == 0.0)) {
                
                // ------------------------------------------
                //    Wrong direction
                // ------------------------------------------
                
                if (!currentDirection) {
                    
                    //   target ahead, but we're heading backwards
                    
                    liveData.velocityCurrent += channel.channelDataSettings.maximumAcceleration
                    
                    // need to be sure we don't overshoot forwards
                    
                    if distanceToTarget < liveData.velocityCurrent {
                        liveData.velocityCurrent = distanceToTarget
                    }
                    
                } else {
                    
                    //   target behind, but we're heading forwards
                    
                    liveData.velocityCurrent -= channel.channelDataSettings.maximumAcceleration
                    
                    //   deal with possibility of overshoot
                    
                    if liveData.velocityCurrent < -distanceToTarget {
                        liveData.velocityCurrent = -distanceToTarget
                    }
                }
                
                setState(.WrongDirection)
                
            } else {
                
                // ---------------------------------------------
                //    Correct direction, or not moving at all
                // ---------------------------------------------
                
                var stoppingFrames = currentSpeed / channel.channelDataSettings.maximumAcceleration
                stoppingFrames = ceil(stoppingFrames)
                var stoppingDistance = 0.0
                if stoppingFrames > 0.0 {
                    stoppingDistance = currentSpeed * 0.5 * stoppingFrames
                }
                
                // ---------------------------------------------
                //    Are we near and slow enough to just jump?
                // ---------------------------------------------
                
                if currentSpeed < channel.channelDataSettings.maximumAcceleration &&
                    distanceToTarget < channel.channelDataSettings.maximumAcceleration {
                        liveData.velocityCurrent = (targetDirection) ? distanceToTarget : -distanceToTarget
                        
                } else {
                    
                    // ---------------------------------------------
                    //    Are going to overshoot?
                    // ---------------------------------------------
                    
                    if abs(distanceToTarget - stoppingDistance) < 0.0 {
                        
                        // ---------------------------------------------
                        //    Overshoot - so decellerate now
                        // ---------------------------------------------
                        
                        if (targetDirection) {
                            
                            liveData.velocityCurrent -= channel.channelDataSettings.maximumAcceleration
                            
                            // ---------------------------------------------
                            //    Check we won't overshoot the other way
                            // ---------------------------------------------
                            
                            if distanceToTarget < liveData.velocityCurrent {
                                liveData.velocityCurrent = distanceToTarget
                            }
                            
                        } else {
                            
                            liveData.velocityCurrent -= channel.channelDataSettings.maximumAcceleration
                            
                            // ---------------------------------------------
                            //    Check we won't overshoot the other way
                            // ---------------------------------------------
                            
                            if liveData.velocityCurrent < -distanceToTarget {
                                liveData.velocityCurrent = -distanceToTarget
                            }
                        }
                        
                        setState(.Overshoot)
                        
                    } else {
                        
                        // ---------------------------------------------
                        //    Not in danger of overshoot - but are we
                        //    in the stopping band?
                        // ---------------------------------------------
                        
                        if (distanceToTarget) < (stoppingDistance + currentSpeed) {
                            
                            // ---------------------------------------------
                            //    Yes - we need to be slowing down
                            //    We're in the stopping band - within a frame
                            //    of the stopping distance to the target.
                            //    Could only be slightly over, could be
                            //    we have a whole extra frame to spend
                            //    slowing.
                            //
                            // ---------------------------------------------
                            
                            setState(.InStoppingBand)
                            
                            print ("In Stopping band...")
                            
                            finalDecel = true
                            
                            var theDecelFrames = (distanceToTarget * 2) / currentSpeed
                            
                           // if theDecelFrames != floor(theDecelFrames) {
                              // there will be a remainder//  theDecelFrames += 1.0
                          //  }
                            //theDecelFrames = floor(theDecelFrames)
                            
                            if (theDecelFrames < 1.0) {
                                if (targetDirection) {
                                    liveData.velocityCurrent = distanceToTarget
                                } else {
                                    liveData.velocityCurrent = -distanceToTarget
                                }
                                setState(.FinalFrame)
                            } else {
                                
                                let theDecel = currentSpeed / theDecelFrames
                                if (targetDirection) {
                                    liveData.velocityCurrent -= theDecel
                                } else {
                                    liveData.velocityCurrent += theDecel
                                }
                                
                                
                                
                                
                                finalDecelRate = theDecel
                                finalDecelFrames = theDecelFrames - 1.0
                                
                                print ("------decel: \(theDecel), distance to target is \(distanceToTarget), velocity is \(liveData.velocityCurrent), expected frames = \(theDecelFrames)")
                            }
                        } else {
                            
                            // ---------------------------------------------
                            //    Not in stopping band or overshooting:
                            //
                            //    Check our speed (max speed could have
                            //    been changed by the user):
                            // ---------------------------------------------
                            
                            if (currentSpeed > channel.channelDataSettings.maximumSpeed) {
                                
                                if currentDirection {
                                    liveData.velocityCurrent = max(channel.channelDataSettings.maximumSpeed, (liveData.velocityCurrent - channel.channelDataSettings.maximumAcceleration))
                                } else {
                                    liveData.velocityCurrent = min(-channel.channelDataSettings.maximumSpeed, (liveData.velocityCurrent + channel.channelDataSettings.maximumAcceleration))
                                    
                                }
                                
                                setState(.SlowingFromOverspeed)
                                
                            } else {
                                
                                // ---------------------------------------------
                                //    Are we at max speed?
                                // ---------------------------------------------
                                
                                if currentSpeed == channel.channelDataSettings.maximumSpeed {
                                    
                                    // ---------------------------------------------
                                    //    Yes, so carry on coasting
                                    // ---------------------------------------------
                                    
                                    setState(.Coasting)
                                    
                                } else {
                                    
                                    // ---------------------------------------------
                                    //    Not at max speed, not in stopping zone
                                    //
                                    //    Can we speed up?
                                    //
                                    //    How much distance do we have to play with?
                                    //    Can only speed up if this extra
                                    //    accel / decel won't push us into
                                    //    the stopping zone.
                                    // ---------------------------------------------
                                    
                                    let stoppingZone = stoppingDistance + currentSpeed
                                    let distanceToStoppingZone = distanceToTarget - stoppingZone
                                    
                                    // ---------------------------------------------
                                    //    If we accelerate, we need to decellerate
                                    //    so there's no point if we haven't time
                                    //    to do both
                                    // ---------------------------------------------
                                    
                                    let distanceTravelledInTwoFramesAtCurrentSpeed = currentSpeed * 2
                                    
                                    if distanceToStoppingZone > distanceTravelledInTwoFramesAtCurrentSpeed {
                                        
                                        // ---------------------------------------------
                                        //    Extra distance that we could use for
                                        //    acceleration lets us cap the max accel
                                        // ---------------------------------------------
                                        
                                        var maximumAccelerationPossible = min(channel.channelDataSettings.maximumAcceleration, distanceToStoppingZone - distanceTravelledInTwoFramesAtCurrentSpeed)
                                        
                                        maximumAccelerationPossible = min(maximumAccelerationPossible, channel.channelDataSettings.maximumSpeed)
                                        
                                        if (targetDirection) {
                                            liveData.velocityCurrent += maximumAccelerationPossible
                                        } else {
                                            liveData.velocityCurrent -= maximumAccelerationPossible
                                        }
                                        
                                        setState(.Accelerating)
                                        
                                    } else {
                                        
                                        // ---------------------------------------------
                                        //    Not enough distance to accel, so just
                                        //    carry on
                                        // ---------------------------------------------
                                        
                                        setState(.Coasting)
                                    }
                                }
                            }}
                    }
                }
            }
        }
        
        liveData.positionActual += liveData.velocityCurrent
        if (channel.channelDataPersistent.channelInterfaceID == 5) {
            print (" -- velocity: \(liveData.velocityCurrent), position: \(liveData.positionActual)")
        
        }
        
    }
    
    
    // -----------------------------------------------------------------------
    //
    //      Hardware Translation functions
    //
    //      take a channel, translate the actualPosition into actualSteps and
    //      return the delta
    //
    //
    // -----------------------------------------------------------------------
    
    /*
    
    func getFreshDeltaForStepper(channel: Channel) -> Int {
    let myDelta = Int(channel.positionActual * Double(channel.scale)) - channel.positionActualSteps
    channel.positionActualSteps += myDelta
    return (myDelta)
    }
    
    
    func getFreshDeltaForLens(channel: Channel) -> Int {
    let steps = LensHandler().getLensStepsFromDistance(channel.positionActual)
    let myDelta = steps - channel.positionActualSteps
    channel.positionActualSteps = steps
    return myDelta
    }
    
    */
    
    
    // -----------------------------------------------------------------------
    //
    //      HOMING
    //
    //
    // -----------------------------------------------------------------------
    
    /*
    
    func calcFrameForHoming(channel: Channel) {
    
    if (channel.homingState == .AccelToward) {
    if (channel.homeSensorClosed) {
    channel.homePositionEstimate = channel.positionActual
    channel.homePositionEstimateError = abs(channel.velocityCurrent)
    channel.homingState = .DecelToward
    print("Homing: \(channel.homingState)")
    print("-- homePosEstimate is \(channel.homePositionEstimate) and current position is \(channel.positionActual), and error is \(channel.homePositionEstimateError)")
    
    } else {
    channel.velocityCurrent -= channel.homingAcceleration
    if channel.velocityCurrent < -channel.homingSpeed {
    channel.velocityCurrent = -channel.homingSpeed
    }
    }
    }
    
    if (channel.homingState == .DecelToward) {
    if (channel.velocityCurrent == 0.0) {
    
    let distanceToErrorZone = abs ((channel.homePositionEstimate - channel.positionActual)) + channel.homePositionEstimateError
    channel.homingSpeed = sqrt(distanceToErrorZone * channel.homingAcceleration)
    
    channel.homingState = .AccelBack
    print("Homing: \(channel.homingState) - dist to errorzone is \(distanceToErrorZone) and homingSpeed set to \(channel.homingSpeed)")
    
    
    }
    channel.velocityCurrent += channel.homingAcceleration
    if channel.velocityCurrent >= 0.0 {
    channel.velocityCurrent = 0.0
    }
    }
    
    if (channel.homingState == .AccelBack) {
    channel.velocityCurrent += channel.homingAcceleration
    if (channel.velocityCurrent >= channel.homingSpeed) {
    channel.homingState = .DecelBack
    print("Homing: \(channel.homingState)")
    
    }
    }
    
    if (channel.homingState == .DecelBack) {
    if (channel.velocityCurrent == 0.0) {
    channel.homingState = .CreepForward
    print("Homing: \(channel.homingState)")
    
    } else {
    channel.velocityCurrent -= channel.homingAcceleration
    if (channel.velocityCurrent < 0.0) {
    channel.velocityCurrent = 0.0
    }
    }
    }
    
    if (channel.homingState == .CreepForward) {
    if (!channel.homeSensorClosed) {
    channel.velocityCurrent = 0.0
    channel.positionActual = channel.homeSwitchPosition
    channel.positionActualSteps = Int( channel.positionActual * Double(channel.scale))
    channel.homingState = .Finished
    print("Homing: \(channel.homingState)")
    
    } else {
    channel.velocityCurrent = 1.0 / Double(abs(channel.scale))
    }
    }
    
    if (channel.homingState == .Finished) {
    channel.channelState = .Manual
    }
    
    
    // all calcs done, update the channel info
    
    
    channel.positionActual += channel.velocityCurrent
    
    
    }
    
    */
    
    // -----------------------------------------------------------------------
    //
    //      SEQUENCE PLAYBACK
    //
    //
    // -----------------------------------------------------------------------
    
    /*
    
    
    func calcFrameForSequence(theChannel: Channel) {
    
    let kf = sequenceController.keyframeList[theChannel.currentCue]
    
    let myNormalisedTime = Double(theChannel.currentFrame) / ( kf.duration * 25.0 )
    if myNormalisedTime <= 1.0 {
    
    // get position for time - from 0-1.0
    
    var myNewPosition = getEasedPositionFromTime(myNormalisedTime, easeIn: (kf.easeInDuration / kf.duration), easeOut: (kf.easeOutDuration / kf.duration), easeType: 1)
    
    
    
    
    if kf.subjectTriangulated {
    
    // all calcs will be based on slider channel position
    
    myNewPosition *= kf.distance
    myNewPosition += kf.channelPositions.positions[1]
    
    switch theChannel.derivable {
    case .Lookat:
    // calc angle from position
    myNewPosition = getAngleFromPositionAndTime(myNewPosition, theDistance: kf.distance, subjectPosition: kf.subjectPosition)
    break
    case .Focus:
    // calc distance to subject from current Position
    
    myNewPosition = getFocusDistanceFromPosition(myNewPosition, subjectPosition: kf.subjectPosition)
    break
    case .None:
    // can't do anything fresh
    break
    
    }
    } else {
    
    let myChannelDelta = sequenceController.keyframeList[theChannel.currentCue+1].channelPositions.positions[theChannel.channelIndex] - kf.channelPositions.positions[theChannel.channelIndex]
    myNewPosition *= myChannelDelta
    myNewPosition += kf.channelPositions.positions[theChannel.channelIndex]
    
    }
    
    
    
    
    theChannel.velocityCurrent = myNewPosition - theChannel.positionActual
    theChannel.positionActual = myNewPosition
    
    
    } else {
    // normalised time outside 0 - 1 so we're done..?
    if (theChannel.currentCue < (sequenceController.keyframeList.count-2)) {
    theChannel.currentFrame = 0
    theChannel.currentCue++
    theChannel.positionDesired = sequenceController.keyframeList[theChannel.currentCue+1].channelPositions.positions[theChannel.channelIndex]
    
    } else {
    executiveController.channelFinishedAnimation()
    }
    }
    
    
    
    
    theChannel.currentFrame++
    
    //        return Int(myDelta)
    }
    
    */
    
    func logToConsole(string: String) {
        // print(string)
    }
    
    
    
    
    // -----------------------------------------------------------------------
    //
    //      Helper Functions
    //
    //
    // -----------------------------------------------------------------------
    
    
    
    
    func getDistanceToSubject(cameraXPosition: Double, subjectPosition: Position) -> Double {
        let theOpp = subjectPosition.x - cameraXPosition
        let theDistance = sqrt( (subjectPosition.y * subjectPosition.y) + (theOpp * theOpp) )
        return theDistance
    }
    
    func convertDistanceToFocusSteps(theFocusDistance: Double) -> Int {
        let steps = 1320 * (  ( 1 / (theFocusDistance) * 5.1))
        return Int(steps)
    }
    
    func getFocusDistanceFromPosition(cameraXPosition: Double, subjectPosition: Position) -> Double {
        let theOpp = subjectPosition.x - cameraXPosition
        let hypo = sqrt( (subjectPosition.y * subjectPosition.y) + (theOpp * theOpp) )
        //let steps = 1320 * (  ( 1 / (hypo-42) * 5.1))
        return hypo                                                                                                                                                          // ****************************** TO DO
    }
    
    
    func getAngleFromPositionAndTime(cameraXPosition: Double, theDistance: Double, subjectPosition: Position) -> Double {
        var theAngle = 0.0
        let theOpp = subjectPosition.x - cameraXPosition
        let hypo = sqrt( (subjectPosition.y * subjectPosition.y) + (theOpp * theOpp) )
        
        
        
        let myValue = theOpp / hypo
        
        
        
        theAngle = ((180/3.1415926) * asin(myValue))
        
        // print ("LOOKAT: pos \(thePosition)   opp \(theOpp)     hypo \(hypo)       angle \(theAngle)")
        
        //  if subjectY < 0.0 {
        //      theAngle =  -( theAngle )
        //  }
        return theAngle
    }
    
    
    
    
    func getEasedPositionFromTime(time: Double, easeIn: Double, easeOut: Double, easeType: Int) -> Double {
        //  var time = 0.25
        //  var easeIn = 0.25
        //  var easeOut = 0.25
        var thePos = 0.0
        
        
        // Work out distance multiplier
        
        var multiplier: Double = 0.5 * easeIn
        multiplier += 0.5 * easeOut
        multiplier += (1.0 - (easeIn + easeOut))
        
        let distance = (easeIn * easeIn * 0.5) + (easeIn * ((1 - easeOut) - easeIn)) + (easeIn * easeOut * 0.5)
        
        
        if time < easeIn {
            thePos = time * time * 0.5
        } else if time < (1.0 - easeOut) {
            thePos = (easeIn * easeIn * 0.5) + (easeIn * (time - easeIn) ) // + easeOut)))
        } else {
            thePos = (easeIn * easeIn * 0.5) + (easeIn * ((1 - easeOut) - easeIn)) - (0.5 * (easeIn/easeOut) * ((1.0 - time)) *  ((1.0 - time)))  + (easeIn * easeOut * 0.5)
            
            
            //(0.5 * (1.0 - time)  * ( 1.0 - time))
        }
        
        return thePos/distance
    }
    
    
    
    
    
    
    
    
    
    
}