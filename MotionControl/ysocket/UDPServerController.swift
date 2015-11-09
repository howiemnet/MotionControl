//
//  UDPServerController.swift
//  MotionControl
//
//  Created by h on 04/11/2015.
//  Copyright © 2015 slartibartfist. All rights reserved.
//

import Foundation

class UDPServerController {
    
    var online = false;
    var server:UDPServer! = nil
    
    
    func goOnline() {
        server = UDPServer(addr: "127.0.0.1",port: 4950)
        online = true;
    }
    
    func goOffline() {
        server.close()
        online = false;
    }
    
    
    func checkForMessage() -> String? {
        if online {
            var (data, remoteip, remoteport) = server.recv(1024)
            if let d=data {
                if let str = String(bytes: d, encoding: NSUTF8StringEncoding) {
                    //print (str)
                    //print ("from IP \(remoteip), port \(remoteport)")
                    return str
                    
                }
            }
        }
        return nil
    }
    
    
    
    
    
}