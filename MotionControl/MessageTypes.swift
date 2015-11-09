//
//  MessageTypes.swift
//  MotionControl
//
//  Created by h on 20/10/2015.
//  Copyright © 2015 slartibartfist. All rights reserved.
//

import Foundation




enum OutgoingMessageTypes : UInt8 {
      case DisableMotor = 0
      case EnableMotor = 1
      case NextFramePosition = 2
      case StartAnimation = 3
      case StopAnimation = 4
      case GoDirectlyToPosition = 5
      case GetPIDParameters = 7
      case SetPIDParameters = 8
      case StartDataStreaming = 9
      case StopDataStreaming = 10
      case GetLiveData = 16
      case DoDeviceHoming = 104
}



enum IncomingMessageTypes : UInt8 {
      case InterfaceIdentification = 0
      case LiveData = 1
      case PIDParameters = 2
}




func parseInt32(bytes:[UInt8], offset:Int)->Int32{
      
      var pointer = UnsafePointer<UInt8>(bytes)
      pointer = pointer.advancedBy(offset)
      
      let iPointer =  UnsafePointer<Int32>(pointer)
      return iPointer.memory
      
}

func parseFloat32(bytes:[UInt8], offset:Int)->Float32{
      var pointer = UnsafePointer<UInt8>(bytes)
      pointer = pointer.advancedBy(offset)
      
      let fPointer =  UnsafePointer<Float32>(pointer)
      return fPointer.memory
      
}

/*

func insertFloat32IntoBuffer(floatValue: Float32, theBuffer: [UInt8], offset: Int) {
      let tempBuffer: [Float32] = [floatValue]
      let data = NSData(bytes: tempBuffer, length: 4)
      data.getBytes(&parameterBuffer[offset], length: 4)
      //return theBuffer
}*/

func insertInt32IntoBuffer(intValue: Int32, var theBuffer: [UInt8], offset: Int) -> [UInt8] {
      let tempBuffer: [Int32] = [intValue]
      let data = NSData(bytes: tempBuffer, length: 4)
      data.getBytes(&theBuffer[offset], length: 4)
      return theBuffer
}


