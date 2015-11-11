//
//  ChannelHandler.swift
//  MotionControl
//
//  Created by h on 15/10/2015.
//  Copyright © 2015 slartibartfist. All rights reserved.
//

//
//   Possible situations: each channel can be
//     visible / hidden
//     connected / disconnected
//     simulation / live
//
//   startup:
//     load all display channels (per channel preference needs to be stored somewhere)
//     scan for devices
//     when a device comes online:
//          check if it's displayed
//          if it's not, show it
//     when a device goes offline:
//          check if it's an "always display" channel
//          if so, just turn it offline
//
//   what to do about simulation?
//     Use cases: testing stuff offline
//     Is there a benefit to having individual channels in sim mode?
//      - let's say No.
//     What to do about the channel data?
//     Only the position needs storing
//     Homing must be disabled
//     Sequencing and tracjectory stuff should carry on as usual though
//     Sim mode puts the channel offline, hides the offline / hand buttons
//          also doesNo point in being offline and in sim mode
//      ditto for sim mode and hand manual
//
//   ChannelHandler manages sim mode
//   Executive controller only handles sim mode switch
//   Channel Table / UI disables some controls but that's it
//
//   ChannelHandler: when entering sim mode,
//     check nothing's moving (exec controller ought to disable the
//     sim button (and a few others) when channels aren't idle
//     records positions of all channels
//   ? disconnect all interfaces
//     add any missing channels
//     sets sim mode flag
//     starts sim event timer
//
//     when leaving sim mode
//     stops sim event timer
//     resets sim mode flag
//     remove all interfaces?
//     restores positions of all channels (to actual and des pos)
//
//


import Foundation

class ChannelHandler {
    
    // ---- OBJECTS ---- //
    weak var executiveController: ExecutiveController!
    var commsHandler: CommsHandler!
    var channels: [Int:Channel]
    
    var dataAccessQueue: dispatch_queue_t! = nil
    var simulationMode = false
    
    
    // -----------------------------------------------------
    //
    //   Init
    //
    // -----------------------------------------------------
    
    init(handler: ExecutiveController) {
        executiveController = handler
        channels = [Int:Channel]()
        
        dataAccessQueue = dispatch_queue_create("com.howiem.MotionControl.dataAccessQueue", DISPATCH_QUEUE_SERIAL)
        commsHandler = CommsHandler()
        commsHandler.channelHandler = self
    }
    
    // -----------------------------------------------------
    //
    //   Scanning for devices
    //
    // -----------------------------------------------------
    
    func scanForDevices() {
        commsHandler.scanForDevices()
        print ("Scan started")
    }
    
    func notifyScanningStarted() {
        executiveController.notifyScanningStarted()
    }
    
    func notifyScanningFinished() {
        executiveController.notifyScanningFinished()
    }
    
    func channelCount() -> Int {
        return channels.count
    }
    
    
    
    // -----------------------------------
    //
    //   Simulation mode
    //
    // -----------------------------------
    
    
    func startSimMode() {
        simulationMode = true
        commsHandler.startSimMode()
    }
    
    func stopSimMode() {
        simulationMode = false
        commsHandler.stopSimMode()
    }
    
    
    // -----------------------------------
    //
    //   Adding / removing
    //
    // -----------------------------------
    
    
    
    func channelWasAdded(channelID: Int) {
        if let persistData = channelLibrary.getPersistentDataForChannelID(channelID) {
            var settingsData = ChannelDataSettings()
            settingsData.maximumAcceleration = persistData.optimalAcceleration
            settingsData.maximumSpeed = persistData.optimalSpeed
            var liveData = ChannelDataLive()
            liveData.channelState = .QueryingInitialState
            
            channels[channelID] = Channel(handler: self, persist: persistData, settings: settingsData, live: liveData)
            
            executiveController.addChannelWithData(persistData, settings: settingsData, live: liveData)
            
            // get initial state of device
            
            commsHandler.queryInitialState(channelID)
            
            
        }
        
    }
    
    
    func channelWasRemoved(channelID: Int) {
        channels[channelID] = nil
        executiveController.removeChannelWithID(channelID)
    }
    
    
    // -----------------------------------
    //
    //   Live Data access
    //
    // -----------------------------------
    
    func updateDesiredPosition(channelID: Int, newPosition: Double) {
        dispatch_sync(dataAccessQueue) {
            if let channel = self.channels[channelID] {
                channel.channelDataLive.positionDesired = newPosition
                channel.dataUpdated = true
            }
            
        }
        
    }
    
    func updateActualPosition(channelID: Int, newPosition: Double) {
        dispatch_sync(dataAccessQueue) {
            if let channel = self.channels[channelID] {
                channel.channelDataLive.positionActual = newPosition
                channel.dataUpdated = true
            }
            
        }
        
    }
    
    func getCurrentState(channelID: Int) -> ChannelState {
        var returnValue : ChannelState?
        dispatch_sync(dataAccessQueue) {
            returnValue = self.channels[channelID]?.channelDataLive.channelState
            
        }
        return returnValue!
        
    }
    
    func setCurrentState(channelID: Int, newState: ChannelState)  {
        dispatch_sync(dataAccessQueue) {
            if let channel = self.channels[channelID] {
                channel.channelDataLive.channelState = newState
                channel.dataUpdated = true
            }
        }
        
    }
    
    func updateCurrentPositionAndCalcVelocity(channelID: Int, newPosition: Double) {
        dispatch_sync(dataAccessQueue) {
            if let channel = self.channels[channelID] {
                let oldPosition = channel.channelDataLive.positionDesired
                channel.channelDataLive.positionDesired = newPosition
                channel.channelDataLive.velocityCurrent = newPosition - oldPosition
                channel.dataUpdated = true
            }
        }
    }
    
    
    func getLiveData(channelID: Int) -> ChannelDataLive? {
        var returnValue : ChannelDataLive?
        dispatch_sync(dataAccessQueue) {
            returnValue = self.channels[channelID]?.channelDataLive
            
        }
        return returnValue
    }
    
    func updateLiveData(channelID: Int, data: ChannelDataLive) {
        dispatch_sync(dataAccessQueue) {
            if let channel = self.channels[channelID] {
                channel.channelDataLive = data
                channel.dataUpdated = true
            }
        }
    }
    
    func getUpdatedChannelsLiveDataDict() -> [Int:ChannelDataLive] {
        //
        var updatedData = [Int:ChannelDataLive]()
        dispatch_sync(dataAccessQueue) {
            for (index, chan) in self.channels {
                if chan.dataUpdated {
                    updatedData[index] = chan.channelDataLive
                    chan.dataUpdated = false
                }
            }
        }
        return updatedData
    }
    
    func getPositionDict() -> [Int:Double] {
        var positionDict = [Int:Double]()
        dispatch_sync(dataAccessQueue) {
            for (id, chan) in self.channels {
                positionDict[id] = chan.channelDataLive.positionDesired
            }
        }
        return positionDict
    }
    
    var lockoutExecutive = false
    
    func setPositionDict(positions: [Int:Double]) {
        lockoutExecutive = true
        dispatch_sync(dataAccessQueue) {
            for (id, _) in positions {
                if self.channels[id] != nil {
                    self.channels[id]!.channelDataLive.channelState == .Moving
                }
            }
        }
        for (id, chan) in positions {
            self.channelDesiredPositionMove(id, newValue: chan)
        }
        lockoutExecutive = false
    }
    
    // -----------------------------------
    //
    //   commands from User Interface
    //
    // -----------------------------------
    
    func channelDesiredPositionMove(channelID: Int, newValue: Double) {
        print ("Move ID \(channelID) to \(newValue)")
        
        // check state of channel
        // if manual control then
        if let channel = channels[channelID] {
            channel.trajectoryHandler.setNewPositionDesired(newValue)
            dispatch_sync(dataAccessQueue) {
                if channel.channelDataLive.channelState == .Idle {
                    channel.channelDataLive.channelState = .Moving
                }
                if channel.channelDataLive.channelState == .Moving {
                    channel.channelDataLive.positionDesired = newValue
                    
                    channel.dataUpdated = true
                }
            }
            
            
        }
    }
    
    func channelSettingsChange(channelID: Int, mSpeed: Double, mAccel: Double) {
        if let channel = channels[channelID] {
            channel.trajectoryHandler.setNewSpeedAndAccel(mSpeed, mAccel: mAccel)
        }
    }
    
    func channelMotorEnable(channelID: Int, enable: Bool) {
        if let channel = channels[channelID] {
            if enable == true {
                setCurrentState(channelID, newState:.Idle)
                // make sure trajectory handler is up to date
                channel.trajectoryHandler.liveData = channel.channelDataLive
                channel.trajectoryHandler.positionDesired = channel.channelDataLive.positionDesired
                channel.trajectoryHandler.currentState = .StoppedAtTarget
                
            } else {
                setCurrentState(channelID, newState:.HandControl)
                
            }
            channel.trajectoryHandler.liveData.channelState = channel.channelDataLive.channelState
            commsHandler.messageMotorEnable(channelID, enable: enable)
        }
    }
    
    
    func stopAllChannels() {
        var chansToStop = 0
        for (_,channel) in channels {
            if channel.trajectoryHandler.currentState != .StoppedAtTarget {
                chansToStop += 1
                channel.trajectoryHandler.stopNow()
            }
        }
        if chansToStop == 0 {
            executiveController.notifyChannelsMoving(0)
        }
    }
    
    
    // -------------------------------------------
    //
    //   Respond to incoming hardware messages
    //
    // -------------------------------------------
    
    func handleIncomingMessageFromChannelID(channelID: Int, bytes: [UInt8]) {
        
        if let channel = channels[channelID] {
            if bytes[1] == IncomingMessageTypes.LiveData.rawValue {
                var state = channel.channelDataLive.channelState
                
                let incomingState = bytes[2]
                if incomingState == 4 {
                    print("Channel (ID: \(channelID)) reported ran out of frames ###############################")
                    //state = .Idle
                }
                
                switch state {
                case .HandControl:
                    var liveData = ChannelDataLive()
                    liveData.channelState = state
                    liveData.positionActual = Double(parseFloat32(bytes, offset: 4)) / channel.channelDataPersistent.scale
                    liveData.positionDesired = liveData.positionActual
                    liveData.homeSensorClosed = ((bytes[2] & 64) == 64) ? true : false;
                    updateLiveData(channelID, data: liveData)
                    break
                case .Moving:
                    if (bytes[3] & 0x01) == 0x01 {
                        // needs more data
                        let hs = ((bytes[2] & 64) == 64) ? true : false;
                        sendNextFrame(channelID, homeSwitch: hs)
                    }
                    break
                case .QueryingInitialState:
                    
                    // find out if motor is on or offline,
                    // get current motor position
                    var liveData = ChannelDataLive()
                    if channel.channelDataPersistent.actuatorType == ActuatorType.LensAF {
                    
                        liveData.positionActual = 0.0 //Double(parseFloat32(bytes, offset: 4)) / channel.channelDataPersistent.scale
                        
                    } else {
                        liveData.positionActual = Double(parseFloat32(bytes, offset: 4)) / channel.channelDataPersistent.scale
                        
                    }
                    liveData.positionDesired = liveData.positionActual
                    if bytes[2] == 0 {
                        liveData.channelState = .HandControl
                    } else {
                        liveData.channelState = .Idle
                        //channel.channelDataLive.channelState = .Idle
                        // make sure trajectory handler is up to date
                        channel.trajectoryHandler.liveData = liveData
                        channel.trajectoryHandler.positionDesired = channel.channelDataLive.positionDesired
                        channel.trajectoryHandler.currentState = .StoppedAtTarget
                        channel.trajectoryHandler.liveData.channelState = channel.channelDataLive.channelState
                    }
                    
                    updateLiveData(channelID, data: liveData)
                    executiveController.updateAllUIForChannel(channelID, data: liveData)
                    break
                default:
                    break
                }
            }
        }
    }
    
    
    // -----------------------------------
    //
    //   Respond to incoming messages
    //
    // -----------------------------------
    
    
    
    
    func sendNextFrame(channelID: Int) {
        if let nextFrameData = channels[channelID]?.trajectoryHandler.getNextFrame() {
            updateLiveData(channelID, data: nextFrameData)
            commsHandler.sendNextFrameData(channelID, liveData: nextFrameData)
            
        }
    }
    
    
    func sendNextFrame(channelID: Int, homeSwitch: Bool) {
        if var nextFrameData = channels[channelID]?.trajectoryHandler.getNextFrame() {
            nextFrameData.homeSensorClosed = homeSwitch
            updateLiveData(channelID, data: nextFrameData)
            commsHandler.sendNextFrameData(channelID, liveData: nextFrameData)
            
        }
    }
    
    
    func preparePlaybackData(motionData: [Int:[Double]]) {
        for (channelID, data) in motionData {
            if let channel = channels[channelID] {
                channel.trajectoryHandler.preparePlaybackStream(data)
            }
        }
        
        
        
        
        
    }
    
    func homeOneChannel(channelID: Int) {
        if let _ = channels[channelID] {
            commsHandler.sendDeviceHomeMessage(channelID);
        }
    }
    
    var currentPlaybackFrame = 0
    
    func latestFrameSent(frameNumber: Int) {
        if frameNumber > currentPlaybackFrame {
            currentPlaybackFrame = frameNumber
            notifyCurrentFrameChanged()
        }
    }
    
    func notifyCurrentFrameChanged() {
        executiveController.currentPlaybackFrameChanged(currentPlaybackFrame)
        commsHandler.updateRemoteDisplayFrame(currentPlaybackFrame)
    }
    
    func notifyExecutiveStateChanged(status: ExecutiveState) {
        commsHandler.updateRemoteDisplayStatus(status)
    }
    
    
    
    
    
    
    func startPlayback() {
        currentPlaybackFrame = 0
        notifyCurrentFrameChanged()
        for (_, chan) in channels {
            chan.trajectoryHandler.startPlayback()
        }

    }
    
    
    func persistentDataForChannelID(channelID: Int) -> ChannelDataPersistent? {
        return channels[channelID]?.channelDataPersistent
    }
    
    func trajectoryStarted(channelID: Int) {
        print ("Traj start")
        if let channel = channels[channelID] {
            dispatch_sync(dataAccessQueue) {
                channel.channelDataLive.channelState = .Moving
            }
            channel.trajectoryHandler.liveData.channelState = .Moving
            sendNextFrame(channelID)
            //            commsHandler.sendNextFrameData(channelID, liveData: channel.channelDataLive)
        }
        updateExecutiveWithChannelsMoving()
        
    }
    func trajectoryFinished(channelID: Int) {
        print ("Traj fin")
        
        if let channel = channels[channelID] {
            channel.channelDataLive.channelState = .Idle
            channel.trajectoryHandler.liveData.channelState = .Idle
            
        }
        updateExecutiveWithChannelsMoving()
    }
    
    func updateExecutiveWithChannelsMoving() {
        if !lockoutExecutive {
            var chansMoving = 0
        dispatch_sync(dataAccessQueue) {
            for (_, chan) in self.channels {
            if chan.channelDataLive.channelState == .Moving {
                chansMoving++
            }
        }
        }
        executiveController.notifyChannelsMoving(chansMoving)
    }
    }
    
    
    func getIDForName(name: String) -> Int? {
        for (id, chan) in channels {
            if chan.channelDataPersistent.channelName == name {
                return id
            }
        }
        return nil
    }
    
}