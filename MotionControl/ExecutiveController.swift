//
//  ExecutiveController.swift
//  MotionControl
//
//  Created by h on 21/07/2015.
//  Copyright © 2015 slartibartfist. All rights reserved.
//
//
//  All communications between the UI and everything else
//  goes through this controller. This should (!) make it
//  a bit simpler to add remote control.
//
//
//
//

import Cocoa

class ExecutiveController: NSObject {
   
    // ---- EXECUTIVE STATE ---- //
    enum ExecutiveState: String {
        case Offline = "Offline"
        case Idle = "Idle"
        case ScanningForDevices = "Scanning for devices"
        case ManualMovingToTarget = "Manual: Channels moving"
        case Stopping = "Stopping"
        case AnimationMovingToStart = "Moving to first animation position"
        case AnimationPausingBeforePlayback = "Pausing before playback"
        case AnimationPlaying = "Playing animation"
        case HomingChannels = "Homing channels"
    }

      
      var simulationMode = false
      
      @IBOutlet weak var simulatorButton: NSButton!

      @IBAction func simulatorButton(sender: NSButton) {
            print ("Sim mode turned: \(sender.integerValue)")
            if (sender.state == NSOnState) {
                  simulationMode = true
                  channelHandler.startSimMode()
            } else {
                  simulationMode = false
                  channelHandler.stopSimMode()
            }
      }
    // ---- OUTLETS ---- //
    @IBOutlet weak var sequenceController: SequenceController!
    @IBOutlet weak var mainViewController: MainWindowViewController!
    @IBOutlet weak var channelTableView: ChannelTableView!
    @IBOutlet weak var blenderPlaybackController: BlenderPlaybackController!
      
    // ---- OBJECTS ---- //
    weak var viewController : ViewUpdateDelegate?
    var channelHandler : ChannelHandler!
    var udpServerController : UDPServerController!
    
    // ---- TIMER ---- //
    var UIUpdateTimer: NSTimer? = nil
    var UIUpdateInterval: NSTimeInterval = 0.04
    
    // ---- STATE VARIABLES ---- //
    var executiveState = ExecutiveState.Offline
  
    
    // -----------------------------------------------------
    //
    //   Init
    //
    // -----------------------------------------------------
    
    
    override init () {
        super.init()
        updateStatus(ExecutiveState.Offline)
        
        // ---- set up display refresh timer ---- //
        
        setupDisplayRefreshTimer()
        
        
        // ---- start the first device scan ---- //
        udpServerController = UDPServerController()
        channelHandler = ChannelHandler(handler: self)
    }

    
    
    
    // -----------------------------------------------------
    //
    //   Display refresh timer
    //
    // -----------------------------------------------------
    
    func setupDisplayRefreshTimer() {
        self.UIUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(self.UIUpdateInterval, target: self, selector: "updateUI", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer((self.UIUpdateTimer)!, forMode: NSRunLoopCommonModes)

    }
    
    
    // ---- UI Update method ---- //
    
    func updateUI() {
        if let udpMessage = udpServerController.checkForMessage() {
            print ("message received")
            let csvData = CSwiftV(String: udpMessage)
            print ("values: \(csvData.rows)")
            var posDict = [Int: Double]()
            for col in 0...csvData.headers.count-1 {
                posDict[Int(csvData.headers[col])!] = Double(csvData.rows[0][col])!
            }
            print ("PosDict: \(posDict)")
            setCurrentChannelPositions(posDict)
            
        }
        
        // on each call,
        // find out if any of the channels have updated
        // and if so, send the updated stuff to the VC
        for (chanID, theLiveData) in channelHandler.getUpdatedChannelsLiveDataDict() {
            // pass updated data to the VC
            channelTableView.updateLiveDataForChannel(chanID, liveData: theLiveData)
        }
        
    }
    
    func updateAllUIForChannel(channelID: Int, data: ChannelDataLive) {
        channelTableView.updateAllDataForChannel(channelID, liveData: data)
    }
    
// -----------------------------------------------------
//
//   Status update
//
// -----------------------------------------------------
    
//    var oldChannelsMoving = 99
    var channelsMoving = 0
    
    
    func updateStatus(newState: ExecutiveState) {
        if (newState != executiveState) {
            print ("State update: \(newState)")
            executiveState = newState
            viewController?.updateStatus(newState.rawValue)
        }
    }
    
    
//-----------------------------------------------------
//
//  Add / remove channels - just pass through to VC
//
// -----------------------------------------------------

    func addChannelWithData(persist: ChannelDataPersistent, settings: ChannelDataSettings, live: ChannelDataLive) {
        channelTableView.addNewChannel(persist, settings: settings, live: live)
    }

    func removeChannelWithID(channelID: Int) {
        channelTableView.removeChannelWithID(channelID)
    }

    
    
// -----------------------------------------------------
//
//   Incoming messages from UI
//
// -----------------------------------------------------

    
    
    func channelOnlineChange(theChan: Channel) {
/*
        print ("channelOnlineChange: \(theChan.channelName) is now \(theChan.online)")
        if (theChan.online) {
            // let's go online
            theChan.velocityCurrent = 0
          //  theChan.hardwareInterface?.goOnline()
          //  theChan.hardwareInterface?.sendTriggerPacket()
        } else {
          //  theChan.hardwareInterface?.goOffline()
            theChan.velocityCurrent = 0
            //theChan.hardwareInterface = nil
        }*/
    }
    
    func homeAllChannels() {
  //      for channel in channelData {
  //          channel.startHoming()
  //      }
    }
    
    
    func homeOneChannel(channelID: Int) {
        channelHandler.homeOneChannel(channelID)
    }
    
    func startSequencePlayback() {
    }
    
    func channelDesiredPositionMove(channelID: Int, newValue: Double) {
        channelHandler.channelDesiredPositionMove(channelID, newValue: newValue)
    }
      
      func settingsChange(channelID:Int, mSpeed: Double, mAccel: Double) {
            channelHandler.channelSettingsChange(channelID, mSpeed: mSpeed, mAccel: mAccel)
      }
    
    func channelMotorEnable(channelID: Int, enable: Bool) {
        channelHandler.channelMotorEnable(channelID, enable: enable)
    }
    
    var masterOnlineState : Bool = false {
        willSet {
            if newValue != masterOnlineState {
                if (true == masterOnlineState) {
                    print ("Going offline")
                    
                } else {
                    print ("Going omline")
  //                  for channel in channelData {
                       // channel.hardwareInterface?.sendTriggerPacket()
  //                  }
                    
                }
            }
        }
        
    }
    
// -----------------------------------------------------
//
//   Requests from sequence controller
//
// -----------------------------------------------------

    
    
    func getCurrentChannelPositions() -> [Int: Double] {
        return channelHandler.getPositionDict()
    }

    func setCurrentChannelPositions(positionDict: [Int: Double]) {
        channelHandler.setPositionDict(positionDict)
    }

    
    
    
    func scanForDevices() {
        channelHandler.scanForDevices()
    }
    
    
    func notifyScanningStarted() {
        updateStatus(ExecutiveState.ScanningForDevices)
    }
    
    func notifyScanningFinished() {
        print("\(channelHandler.channelCount())")
        if channelHandler.channelCount() == 0 {
            updateStatus(ExecutiveState.Idle)       // though actually offline
        } else {
            updateStatus(ExecutiveState.Idle)
            
        }
    }
    
    func notifyChannelsMoving(chansMoving: Int) {
        channelsMoving = chansMoving
        if (channelsMoving == 0) {
            
            switch executiveState {
            case .ManualMovingToTarget:
                updateStatus(ExecutiveState.Idle)
            case .Stopping:
                updateStatus(ExecutiveState.Idle)
                
            case .AnimationMovingToStart:
                updateStatus(ExecutiveState.AnimationPausingBeforePlayback)
                channelHandler.preparePlaybackData(blenderPlaybackController.getDataStreamsForAllChannels())
                let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
                dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
                    self.triggerStartOfAnimation()
                }
            case .AnimationPlaying:
                //updateUIForAllChannels()
                updateStatus(ExecutiveState.Idle)
            default:
                break
            }
        } else {
            if executiveState == .Idle {
                updateStatus(ExecutiveState.ManualMovingToTarget)
            }
        }
        viewController?.channelsMoving = chansMoving
    }
    
    func triggerStartOfAnimation() {
        updateStatus(ExecutiveState.AnimationPlaying)
        // trigger channels to do their move
        channelHandler.startPlayback()
    }
    
    func getIDForName(name: String) -> Int? {
        return channelHandler.getIDForName(name)
    }
    
    
    // -----------------------------------------------------
    //
    //   Blender playback control
    //
    //
    // -----------------------------------------------------

    func requestStartPlayback() {
        // wait until channels are all stopped
        // (stop them?)
        // move to first position
        // delay for a sec
        // start playback
        if executiveState == .Idle {
            updateStatus(ExecutiveState.AnimationMovingToStart)
            setCurrentChannelPositions(blenderPlaybackController.getPositionsForFirstFrame())
        }
        
    }
    
    func requestStopPlayback() {
        updateStatus(ExecutiveState.Stopping)
        channelHandler.stopAllChannels()
    }


    // -----------------------------------------------------
    //
    //   Blender LIVE mode
    //
    //
    // -----------------------------------------------------
    
    func liveModeEnable() {
        udpServerController.goOnline()
        viewController?.updateLiveModeButton(true)
    }
    
    func liveModeDisable() {
        udpServerController.goOffline()
        viewController?.updateLiveModeButton(false)
        
    }



}




