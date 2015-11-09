//
//  SerialInterface.swift
//  MotionControl
//
//  Created by h on 21/07/2015.
//  Copyright © 2015 slartibartfist. All rights reserved.
//

import Foundation

enum InterfaceStatusMessage {
    case InterfaceWentOnline
    case InterfaceWentOffline
}


class SerialInterface: NSObject, HardwareInterface, ORSSerialPortDelegate {
    
    
    
    
    
    weak var commsHandler: CommsHandler!
    
    var online = false
    var path = String()
    var channels = [Int]()
    var interfaceNumber = 0
    var openTimeout = false
    var helloTimeout = false
    var slow = false
    
    var outgoingBuffer = Array(count: 64, repeatedValue: UInt8(0))
    
    var serialPort: ORSSerialPort?

    
    
    
    // -------------------------------------------------------------------
    //
    //   INIT
    //
    // -------------------------------------------------------------------
    
    
    required init(theHandler: CommsHandler, iinterfaceNumber: Int) {
        super.init()
        interfaceNumber = iinterfaceNumber
        commsHandler = theHandler
        
    }
    
    
    
    
    // -------------------------------------------------------------------
    //
    //   Open and close
    //
    // -------------------------------------------------------------------
    
    
    func open () {
        serialPort = ORSSerialPort(path: self.path)
        serialPort?.baudRate = 115200
        serialPort?.delegate = self
        serialPort?.open()
        openTimeout = true
        let delaySeconds = (slow) ? 3.0 : 1.5
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delaySeconds * Double(NSEC_PER_SEC)))
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            self.checkForOpenTimeout()
        }

    }
    
    
    func close () {
        if (online) {
            self.serialPort?.close()
            online = false
        }
    }

    
    
    
    // -------------------------------------------------------------------
    //
    //   writeData
    //
    // -------------------------------------------------------------------

    
    func writeData (theData: NSData) {
        if (online){
            if slow {
                var shortBuffer = Array(count:8, repeatedValue: UInt8(0))
                theData.getBytes(&shortBuffer, length: 8)
                let shortenedData = NSData(bytes: shortBuffer, length: 8)
                print ("Sending SHORTDATA: \(shortenedData)")
                self.serialPort?.sendData(shortenedData)
                
            } else {
                self.serialPort?.sendData(theData)
                
            }
        } else {
            print ("Tried to write to closed port")
        }
    }



    // -------------------------------------------------------------------
    //
    //   Receive data
    //
    //   Has to handle situations where partial buffers arrive
    //
    // -------------------------------------------------------------------


    var midBuffer = false;
    var charsReceived = 0;
    var incomingBuffer = Array(count: 64, repeatedValue: UInt8(0))
    
    
    func serialPort(serialPort: ORSSerialPort, didReceiveData data: NSData) {
        print ("Received \(data.length) chars from serial port: \(data)")
        
        var bytes = Array(count: 64, repeatedValue: UInt8(0))
        
        if (!slow) {
            
            data.getBytes(&bytes, length: 64)
            processBuffer(bytes)
        
        } else {
            
            // copy data into the incoming buffer
            // if there are 8 bytes or more
            // copy the first 8 bytes into another buffer ready to process
            // then move any remaining bytes back 8 bytes
            
            data.getBytes(&(incomingBuffer[charsReceived]), length: data.length)
            charsReceived += data.length
            while (charsReceived > 7) {
                for i in 0...7 {
                    bytes[i] = incomingBuffer[i]
                }
                processBuffer(bytes)
                charsReceived -= 8
                if charsReceived > 0 {
                    // move everything back
                    for i in 0..<charsReceived {
                        incomingBuffer[i] = incomingBuffer[8+i]
                    }
                }
            }
            
        }
        
        
    }
    
    
    
    
    
    func processBuffer(bytes: [UInt8]) {
        // Check if it's an interface message (ie something to handle here)
        //print("Processing buffer: \(bytes)")
        if bytes[0] == IncomingMessageTypes.InterfaceIdentification.rawValue {
            // interface message
            if bytes[1] == 1 {
                // confident it's one of our devices :)
                helloTimeout = false
                // channel count message
                for i in 0..<Int(bytes[2]) {
                    let channelID = Int(bytes[3+i])
                    channels.append(channelID)
                    commsHandler.notifyChannelAdded(interfaceNumber, channelID: channelID)
                }
            }
            
        } else {
            
            // pull out channel and format as channel message, pass to commshandler
            
            if channels.count > 0 {
                commsHandler.messageReceivedFromChannel(channels[0], bytes: bytes)
            }
        }
    }
    
    func serialPortWasRemovedFromSystem(serialPort: ORSSerialPort) {
        print("Serial port was removed...")
        if channels.count > 0 {
            for chan in channels {
                commsHandler.notifyChannelRemoved(chan)
            }
        }
        commsHandler.interfaceStatusMessage(interfaceNumber, messageType: InterfaceStatusMessage.InterfaceWentOffline)
        //self.serialPort = nil
    }
    
    func serialPort(serialPort: ORSSerialPort, didEncounterError error: NSError) {
        print("Serial port (\(serialPort)) encountered error: \(error)")
    }
    
    func serialPortWasOpened(serialPort: ORSSerialPort) {
        print("Serial port \(serialPort) was opened")
        online = true
        openTimeout = false
        helloTimeout = true
        outgoingBuffer[0] = 105
        if slow {
            let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.5 * Double(NSEC_PER_SEC)))
            dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
                self.sendQueryPacket()
            }

          
        } else {
            sendQueryPacket()
        }
        
        
    }
    
    
    func sendQueryPacket() {
        print("Querying \(serialPort) for channel count")
        
        if (slow) {
            writeData(NSData(bytes: outgoingBuffer, length: 8))
        } else {
            writeData(NSData(bytes: outgoingBuffer, length: 64))
            
        }
        // set up a timer to check if there was no response:
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.5 * Double(NSEC_PER_SEC)))
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            self.checkForHelloTimeout()
        }

    }
    
    
    func checkForHelloTimeout() {
        if helloTimeout {
            close()
            commsHandler.notifyInterfaceDidntRespondToHello(interfaceNumber)
        }
    }
    
    func checkForOpenTimeout() {
        if openTimeout {
            close()
            commsHandler.notifyInterfaceDidntRespondToHello(interfaceNumber)
        }
    }
    
    
    func serialPortWasClosed(serialPort: ORSSerialPort) {
        commsHandler.interfaceStatusMessage(interfaceNumber, messageType: InterfaceStatusMessage.InterfaceWentOffline)
        //self.serialPort = (nil)
    }
    

    
}