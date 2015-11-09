//
//  InterfaceLibrary.swift
//  MotionControl
//
//  Created by h on 15/10/2015.
//  Copyright © 2015 slartibartfist. All rights reserved.
//

import Foundation

enum InterfaceTechnology {
    case Serial
    case SerialSlow
    case USBHID
}

struct HardwareInterfaceData {
    var interfaceTechnology : InterfaceTechnology
    var interfaceName : String
}

class InterfaceLibrary {
    
    func getInterfaceList() -> [HardwareInterfaceData] {
        
        var theList = [HardwareInterfaceData]()
        theList.append(HardwareInterfaceData(interfaceTechnology: .Serial, interfaceName: "/dev/cu.usbmodem1130421"))
        theList.append(HardwareInterfaceData(interfaceTechnology: .Serial, interfaceName: "/dev/cu.usbmodem1131621"))
        theList.append(HardwareInterfaceData(interfaceTechnology: .Serial, interfaceName: "/dev/cu.usbmodem1131261"))
        theList.append(HardwareInterfaceData(interfaceTechnology: .SerialSlow, interfaceName: "/dev/cu.usbserial-A100QBS2"))
        theList.append(HardwareInterfaceData(interfaceTechnology: .SerialSlow, interfaceName: "/dev/cu.usbserial-A800eofQ"))
        theList.append(HardwareInterfaceData(interfaceTechnology: .SerialSlow, interfaceName: "/dev/cu.usbmodem3a21"))
        theList.append(HardwareInterfaceData(interfaceTechnology: .Serial, interfaceName: "/dev/cu.usbmodem1131111"))
        theList.append(HardwareInterfaceData(interfaceTechnology: .Serial, interfaceName: "/dev/cu.usbmodem1143611"))
        //theList.append(HardwareInterfaceData(interfaceTechnology: .USBHID, interfaceName: "USB-Raw-HID"))
        
        return theList
        
    }
    
    
    
}