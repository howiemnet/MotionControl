//
//  ChannelCommsHandler.swift
//  MotionControl
//
//  Created by h on 21/07/2015.
//  Copyright © 2015 slartibartfist. All rights reserved.
//

import Foundation

protocol HardwareInterface: class {
    init (theHandler: CommsHandler, iinterfaceNumber: Int)
    var commsHandler: CommsHandler! {get set}
    var online: Bool {get set}
    var channels: [Int] {get set}
    var path: String {get set}
    var slow: Bool {get set}

    func open ()
    func writeData (theData: NSData)
    func close ()
}
