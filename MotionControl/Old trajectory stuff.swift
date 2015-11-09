//
//  Old trajectory stuff.swift
//  MotionControl
//
//  Created by h on 28/10/2015.
//  Copyright © 2015 slartibartfist. All rights reserved.
//

import Foundation


/* enum TrajectoryPlaybackState {
case Acceleration
case Coasting
case Decelleration
case StoppedAtTarget
}

struct Trajectory {
var trajectoryTarget = Double(0.0)
var accelerationRate = Double(0.0)
var accelerationFrames = Int(0)
var coastingVelocity = Double(0.0)
var coastingFrames = Int(0)
var decellerationRate = Double(0.0)
var decellerationFrames = Int(0)
var currentStateInTrajectory = TrajectoryPlaybackState.StoppedAtTarget
var currentFrameInTrajectoryState = Int(0)
}


var currentTrajectory = Trajectory()

func BLARGLupdateLiveDataForManualMove() {

if (currentTrajectory.trajectoryTarget != liveData.positionDesired) {

// Dirty trajectory...
updateTrajectoryWithNewPosition()
}

if currentTrajectory.currentStateInTrajectory == .Acceleration {
if currentTrajectory.accelerationFrames <= 0 {
currentTrajectory.currentStateInTrajectory = .Coasting
} else {
liveData.velocityCurrent += currentTrajectory.accelerationRate
liveData.positionActual += liveData.velocityCurrent
currentTrajectory.accelerationFrames -= 1
}
}

if currentTrajectory.currentStateInTrajectory == .Coasting {
if currentTrajectory.coastingFrames <= 0 {
currentTrajectory.currentStateInTrajectory = .Decelleration
} else {
//liveData.velocityCurrent = currentTrajectory.coastingVelocity
liveData.positionActual += liveData.velocityCurrent
currentTrajectory.coastingFrames -= 1
}
}

if currentTrajectory.currentStateInTrajectory == .Decelleration {
if currentTrajectory.decellerationFrames <= 0 {
currentTrajectory.currentStateInTrajectory = .StoppedAtTarget
} else {
liveData.velocityCurrent -= currentTrajectory.decellerationRate
liveData.positionActual += liveData.velocityCurrent
currentTrajectory.decellerationFrames -= 1
}
}

if currentTrajectory.currentStateInTrajectory == .StoppedAtTarget {
//channelHandler.trajectoryCompleted()
} else {
//                 print ("P: \(liveData.positionActual) T: \(currentTrajectory)")
}


}


func updateTrajectoryWithNewPosition() {

// ------------------------------------
//  Need to work from existing velocity
//  and position
// ------------------------------------

//---- different cases if we're heading in the right
//     rather than the wrong direction

// for now, let's just deal with starting from idle

if liveData.velocityCurrent == 0 {

// the distance will be covered symmetrically, so divide it by 2
let firstHalf = (liveData.positionDesired - liveData.positionActual) / 2

// will there be a coasting period?
let framesToHitMaxSpeed = channel.channelDataSettings.maximumSpeed / channel.channelDataSettings.maximumAcceleration
let stoppingDistanceAtMaxSpeed = framesToHitMaxSpeed * 0.5 * channel.channelDataSettings.maximumSpeed

if firstHalf > stoppingDistanceAtMaxSpeed {
// yes, there'll be a coasting period
// so calculate it like a trapezoid
} else {
// no coasting period,
// so calculate it like a triangle

// first, calc the number of frames to hit our
// half-distance if we go at max accel
var frames = sqrt( ( firstHalf * 2) / channel.channelDataSettings.maximumAcceleration)

// make sure it's a whole number of frames (by going slower if nec)
if floor(frames) < frames {
frames += 1.0
}

// dist / frames = maxvel / 2
let maxVelocity = 2 * (firstHalf / frames)
currentTrajectory.accelerationFrames = Int(floor(frames))
currentTrajectory.accelerationRate = maxVelocity / frames
currentTrajectory.coastingFrames = 0
currentTrajectory.decellerationFrames = currentTrajectory.accelerationFrames
currentTrajectory.decellerationRate = currentTrajectory.accelerationRate






}
}
currentTrajectory.trajectoryTarget = liveData.positionDesired
currentTrajectory.accelerationRate = Double(0.1)
currentTrajectory.accelerationFrames = Int(10)
currentTrajectory.coastingVelocity = Double(1.0)
currentTrajectory.coastingFrames = Int(10)
currentTrajectory.decellerationRate = Double(0.1)
currentTrajectory.decellerationFrames = Int(10)
currentTrajectory.currentStateInTrajectory = TrajectoryPlaybackState.Acceleration
}


*/

