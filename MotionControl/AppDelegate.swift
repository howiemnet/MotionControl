//
//  AppDelegate.swift
//  MotionControl
//
//  Created by Alan Westbrook on 7/17/15.
//  Copyright (c) 2015 slartibartfist. All rights reserved.
//

import Cocoa

var channelLibrary = ChannelLibrary()


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    //executiveController.initChannels()

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        /*
        In Swift:
        Print the names of all fonts available for this app.
        */
         //channelLibrary.loadLibrary()
     }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }

}


