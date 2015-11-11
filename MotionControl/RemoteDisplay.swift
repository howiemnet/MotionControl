//
//  RemoteDisplay.swift
//  MotionControl
//
//  Created by h on 11/11/2015.
//  Copyright © 2015 slartibartfist. All rights reserved.
//

import Foundation

class RemoteDisplay: NSObject, ORSSerialPortDelegate {
    
    var displayConnected = false
    var serialPort: ORSSerialPort!
    
    // -------------------------------------------------------------------
    //
    //   INIT
    //
    // -------------------------------------------------------------------
    
    
    required override init() {
        super.init()
    }
    
    
    
    
    
    
    func initialiseDisplay(thePath: String) {
        serialPort = ORSSerialPort(path: thePath)
        serialPort.baudRate = 115200
        serialPort.delegate = self
        serialPort.open()
    }
    
    func updateDisplayStatus(string: String) {
        if displayConnected {
            sendData("}" + string)
        }
    }
    
    func updateDisplayTime(value: Int) {
        if displayConnected {
        let theString = "{Frame: \(value)"
        sendData(theString)
        }
    }

    
    func sendData(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding)
        if data != nil {

            self.serialPort.sendData(data!)
        }
    }
    
    func serialPort(serialPort: ORSSerialPort, didReceiveData data: NSData) {
        
    }
    
    func serialPortWasRemovedFromSystem(serialPort: ORSSerialPort) {
        displayConnected = false
          }
    
    func serialPort(serialPort: ORSSerialPort, didEncounterError error: NSError) {
        print("Serial port (\(serialPort)) encountered error: \(error)")
        displayConnected = false
    }
    
    func serialPortWasOpened(serialPort: ORSSerialPort) {
        displayConnected = true
    }

    
    
    
}