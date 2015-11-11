//
//  CommsHandler.swift
//  MotionControl
//
//  Created by h on 15/10/2015.
//  Copyright © 2015 slartibartfist. All rights reserved.
//

import Foundation

class Interface {
      var hardwareInterfaceData: HardwareInterfaceData
      var online: Bool
      var channelCount: Int
      var channelIDs: [Int]
      var hardwareInterface: HardwareInterface?
      
      init(ihardwareInterfaceData: HardwareInterfaceData, ionline: Bool, ichannelCount: Int, ichannelIDs: [Int], ihardwareInterface: HardwareInterface?) {
            hardwareInterfaceData = ihardwareInterfaceData
            online = ionline
            channelCount = ichannelCount
            channelIDs = ichannelIDs
            hardwareInterface = ihardwareInterface
            
      }
      
}



class CommsHandler: NSObject, NSUserNotificationCenterDelegate {
      
      var interfaceList = [Interface]()
      var channelsAndInterfacesList = [Int: Int]()
      weak var channelHandler : ChannelHandler! {
            didSet {
                  //
                  
            }
      }
      let serialPortManager = ORSSerialPortManager.sharedSerialPortManager()
      var numberOfChannelsAwaitingResponse = 0
      var simulationMode = false
    var remoteDisplay = RemoteDisplay()
    
    var outgoingBuffer = Array(count: 64, repeatedValue: UInt8(0))
      
      // ---- TIMER ---- //
      var simUpdateTimer: NSTimer? = nil
      var simUpdateInterval: NSTimeInterval = 0.04
      
      
      
      // ---------------------------------------------
      
      override init() {
            super.init()
            
            //
            // Build the interface list
            //
            
            for iface in InterfaceLibrary().getInterfaceList() {
                  let interface = Interface(ihardwareInterfaceData: iface, ionline: false, ichannelCount: 0, ichannelIDs: [Int](), ihardwareInterface: (nil))
                  interfaceList.append(interface)
            }
            
            //
            // Add observers for serial port connect / disconnect
            // messages
            //
            
            let nc = NSNotificationCenter.defaultCenter()
            nc.addObserver(self, selector: "serialPortsWereConnected:", name: ORSSerialPortsWereConnectedNotification, object: nil)
            nc.addObserver(self, selector: "serialPortsWereDisconnected:", name: ORSSerialPortsWereDisconnectedNotification, object: nil)
            
            
      }
      
      
      deinit {
            disconnectAll()
            NSNotificationCenter.defaultCenter().removeObserver(self)
      }
      
      
      func disconnectAll() {
            for interface in interfaceList {
                  if (interface.hardwareInterface != nil) {
                        for channel in interface.channelIDs {
                              channelHandler.channelWasRemoved(channel)
                        }
                        //                        print("Deinit - closing index \(interface.hardwareInterface!.path)")
                        interface.hardwareInterface!.close()
                  }
            }
            
      }
      
      // ---------------------------------------------
      //
      //  SIMULATION MODE STUFF
      //
      // ---------------------------------------------
      
      func startSimMode() {
            //
            // TODO: disconnect all first!
            //
            disconnectAll()
            simulationMode = true
            addAllDevices()
            startSimulationTimer()
      }
      
      func stopSimMode() {
            stopSimulationTimer()
            simulationMode = false
            removeAllDevices()
            scanForDevices()
      }
      
      
      
      func startSimulationTimer() {
            simUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(simUpdateInterval, target: self, selector: "updateSimulator", userInfo: nil, repeats: true)
            NSRunLoop.mainRunLoop().addTimer((simUpdateTimer)!, forMode: NSRunLoopCommonModes)
            
            
      }
      
      func stopSimulationTimer() {
            simUpdateTimer?.invalidate()
      }
      
      func addAllDevices() {
            for channel in channelLibrary.getAllChannelsPersistentData() {
                  if channel.hide == false {
                        notifyChannelAdded(0, channelID: channel.channelInterfaceID)
                  }
            }
      }
      
      func removeAllDevices() {
            for channel in channelLibrary.getAllChannelsPersistentData() {
                  notifyChannelRemoved(channel.channelInterfaceID)
            }
      }
      
      
      func updateSimulator() {
            for (channelID, _) in channelsAndInterfacesList {
                  let myBytes : [UInt8] = [1,1,3,1,0,0,0]
                  messageReceivedFromChannel(channelID, bytes: myBytes)
            }
            
      }
      
      func scanForDevices() {
            if simulationMode {
                  print ("ERROR - tried to scanfordevices while in sim mode")
            } else {
                  channelHandler.notifyScanningStarted()
                  print ("Starting scan")
                  for (index, interface) in interfaceList.enumerate() {
                        if !interface.online {
                              switch interface.hardwareInterfaceData.interfaceTechnology {
                              case .USBHID:
                                    // do USB stuff
                                    let myUSBDeviceCount = rawhid_open(10, 0x16C0, 0x0486, 0xFFAB, 0x0200)
                                    if myUSBDeviceCount > 0 {
                                          print ("\(myUSBDeviceCount) USB device(s) found")
                                          interface.channelCount = Int(myUSBDeviceCount)
                                          interface.online = true
                                    }
                              case .Serial:
                                    // do Serial stuff
                                    interface.hardwareInterface = SerialInterface(theHandler: self, iinterfaceNumber: index)
                                    interface.hardwareInterface!.path = interface.hardwareInterfaceData.interfaceName
                                    interface.hardwareInterface!.open()
                                    interface.online = true
                                    numberOfChannelsAwaitingResponse += 1
                                    break
                              case .SerialSlow:
                                // do Serial stuff
                                interface.hardwareInterface = SerialInterface(theHandler: self, iinterfaceNumber: index)
                                interface.hardwareInterface!.slow = true
                                interface.hardwareInterface!.path = interface.hardwareInterfaceData.interfaceName
                                interface.hardwareInterface!.open()
                                interface.online = true
                                numberOfChannelsAwaitingResponse += 1
                                break
                              }
                        }
                  }
            }
            if numberOfChannelsAwaitingResponse == 0 {
                  channelHandler.notifyScanningFinished()
            }
        if remoteDisplay.displayConnected == false {
            remoteDisplay.initialiseDisplay("/dev/cu.usbserial-A50285BI")
        }
      }
      
      
      
      func userNotificationCenter(center: NSUserNotificationCenter, didDeliverNotification notification: NSUserNotification) {
            let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3.0 * Double(NSEC_PER_SEC)))
            dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
                  center.removeDeliveredNotification(notification)
            }
      }
      
      func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
            return true
      }
      
      // MARK: - Notifications
      
      func serialPortsWereConnected(notification: NSNotification) {
            if let userInfo = notification.userInfo {
                  let connectedPorts = userInfo[ORSConnectedSerialPortsKey] as! [ORSSerialPort]
                  print("Ports were connected: \(connectedPorts)")
                  let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.5 * Double(NSEC_PER_SEC)))
                  dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
                        self.scanForDevices()
                  }
                  
            }
      }
      
      func serialPortsWereDisconnected(notification: NSNotification) {
            if let userInfo = notification.userInfo {
                  let disconnectedPorts: [ORSSerialPort] = userInfo[ORSDisconnectedSerialPortsKey] as! [ORSSerialPort]
                  print("Ports were disconnected: \(disconnectedPorts)")
                  //self.postUserNotificationForDisconnectedPorts(disconnectedPorts)
            }
      }
      
      
      
      
      
      
      
      
      // ---------------------------------------------
      //
      //    Incoming STATUS handler
      //
      //
      // ---------------------------------------------
      
      func interfaceStatusMessage(interfaceIndex: Int, messageType: InterfaceStatusMessage) {
            switch messageType {
            case .InterfaceWentOnline:
                  // ask for channel count
                  
                  break;
            case .InterfaceWentOffline:
                  // tidy up and inform Exec
                  interfaceList[interfaceIndex].online = false
                  break;
            }
            
      }
    
    func updateRemoteDisplayStatus(status: ExecutiveState) {
      remoteDisplay.updateDisplayStatus(ExecutiveStateStringShort(status))
    }
    
    func updateRemoteDisplayFrame(frame: Int) {
        remoteDisplay.updateDisplayTime(frame)
        
    }
    
      func notifyInterfaceDidntRespondToHello(interfaceIndex: Int) {
            interfaceList[interfaceIndex].online = false
            interfaceList[interfaceIndex].hardwareInterface = nil
            numberOfChannelsAwaitingResponse -= 1
            print ("no response, chans still waiting: \(numberOfChannelsAwaitingResponse)")
            if (numberOfChannelsAwaitingResponse == 0) {
                  channelHandler.notifyScanningFinished()
            }
      }
      
      
      func notifyChannelAdded(interfaceIndex: Int, channelID: Int) {
            
            print ("Channel ID \(channelID) added...")
            
            // add to matrix
            channelsAndInterfacesList[channelID] = interfaceIndex
            
            
            // notify the authorities
            channelHandler.channelWasAdded(channelID)
            if !simulationMode {
                  numberOfChannelsAwaitingResponse -= 1
                  
                  print ("chan added, chans still waiting: \(numberOfChannelsAwaitingResponse)")
                  
                  if (numberOfChannelsAwaitingResponse == 0) {
                        channelHandler.notifyScanningFinished()
                  }
            }
            
            
      }
      
      func notifyChannelRemoved(channelID: Int) {
            print ("Channel ID \(channelID) removed...")
            
            // remove from matrix
            channelsAndInterfacesList[channelID] = nil
            channelHandler.channelWasRemoved(channelID)
      }
      
      
      
      // ---------------------------------------------
      //
      //    Incoming message handler
      //
      // ---------------------------------------------
      
      
      func messageReceivedFromChannel(channelID: Int, bytes: [UInt8]) {
            // handle it (!)
            //print ("Message from channel ID: \(channelID), data: \(bytes)")
            channelHandler.handleIncomingMessageFromChannelID(channelID, bytes: bytes)
            
      }
      
      func sendMessageToChannel(channelID: Int, bytes: [UInt8]) {
            // get interface, channel from ID
            interfaceList[channelsAndInterfacesList[channelID]!].hardwareInterface?.writeData(NSData(bytes: bytes, length: 64))
      }
    
    

    func sendNextFrameData(channelID: Int, liveData: ChannelDataLive) {
       // print("Send frame data: position \(liveData.positionActualSteps)")
        outgoingBuffer[0] = OutgoingMessageTypes.NextFramePosition.rawValue
        outgoingBuffer = insertInt32IntoBuffer(liveData.positionActualSteps, theBuffer: outgoingBuffer, offset: 1)
        sendMessageToChannel(channelID, bytes: outgoingBuffer)
        print("Send frame data: channel \(channelID) to position \(liveData.positionActualSteps)") //, \(outgoingBuffer)")
        
    
    }
    
    func messageMotorEnable(channelID: Int, enable: Bool) {
        outgoingBuffer[0] = (enable == true) ? OutgoingMessageTypes.EnableMotor.rawValue : OutgoingMessageTypes.DisableMotor.rawValue
        sendMessageToChannel(channelID, bytes: outgoingBuffer)
        
    }
    
    func sendDeviceHomeMessage(channelID: Int) {
        outgoingBuffer[0] = OutgoingMessageTypes.DoDeviceHoming.rawValue
        sendMessageToChannel(channelID, bytes: outgoingBuffer)
    }
    
    
    
    func queryInitialState(channelID: Int) {
        outgoingBuffer[0] = 16
        sendMessageToChannel(channelID, bytes: outgoingBuffer)

        
    }
    
      
      
}