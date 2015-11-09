
import Foundation

//--------------------------------------------------------
//
//  Motion Control - Persistent Channel data
//
//
//  Created by h on 14/10/2015.
//
//
//--------------------------------------------------------


enum ActuatorType : Int {
    case Linear = 0
    case Rotational = 1
    case LensAF = 2
}

//enum MotionType :

enum Derivability : Int {
    case None = 0
    case Lookat = 1
    case Focus = 2
}

enum HardwareTranslationType : Int {
    case ServoScale = 0
    case StepperScale = 1
    case LensScale = 2
}

enum HomingType : Int {
    case None = 0
    case HuntForHomeSwitch = 1
    case RequestDeviceHome = 2
}


//--------------------------------------------------------
//
//  ChannelDataPersistent contains static information
//  about known devices
//
//--------------------------------------------------------


class ChannelDataPersistent {
    
    var channelInterfaceID = 5
    var channelName = String()
      var hide = false
      
    
    // actuator information
    
    var actuatorType: ActuatorType = .Linear
    var derivable: Derivability = .None
    var canFeedBackPosition = false
    var canDisableMotor = false
    
    // scales
    
    var displayUnits = String()
    var hardwareTranslation = HardwareTranslationType.StepperScale
    var scale = 0.0                   // this is pulses / steps per displayUnit
    
    // limits
    
    var positionMinimum = 0.0
    var positionMaximum = 0.0
    var positionNudgeSmall = 0.0
    var positionNudgeLarge = 0.0
    
    // physics limits
    
    var optimalSpeed = 0.0
    var optimalAcceleration = 0.0
    var optimalJerk = 0.0
    var maximumSpeed = 0.0
    var maximumAcceleration = 0.0
    var maximumJerk = 0.0
    
    // homing
    
    var homingType: HomingType = .HuntForHomeSwitch
    var homePosition = 0.0          // user-friendly home
    var homeSwitchPosition = 0.0    // actual position of home sensor
    var homingHardLimitExists = false
    var homingHardLimitDistanceFromSensor = 0.0
    
      init() {
            
      }
      
      init(copyFrom: ChannelDataPersistent) {
             channelInterfaceID = copyFrom.channelInterfaceID
             channelName = copyFrom.channelName
            hide = copyFrom.hide
            
            // actuator information
            
             actuatorType = copyFrom.actuatorType
             derivable = copyFrom.derivable
             canFeedBackPosition = copyFrom.canFeedBackPosition
             canDisableMotor = copyFrom.canDisableMotor
            
            // scales
            
             displayUnits = copyFrom.displayUnits
             hardwareTranslation = copyFrom.hardwareTranslation
             scale = copyFrom.scale                   // this is pulses / steps per displayUnit
            
            // limits
            
             positionMinimum = copyFrom.positionMinimum
             positionMaximum = copyFrom.positionMaximum
             positionNudgeSmall = copyFrom.positionNudgeSmall
             positionNudgeLarge = copyFrom.positionNudgeLarge
            
            // physics limits
            
             optimalSpeed = copyFrom.optimalSpeed
             optimalAcceleration = copyFrom.optimalAcceleration
             optimalJerk = copyFrom.optimalJerk
             maximumSpeed = copyFrom.maximumSpeed
             maximumAcceleration = copyFrom.maximumAcceleration
             maximumJerk = copyFrom.maximumJerk
            
            // homing
            
             homingType = copyFrom.homingType
             homePosition = copyFrom.homePosition        // user-friendly home
             homeSwitchPosition = copyFrom.homeSwitchPosition    // actual position of home sensor
             homingHardLimitExists = copyFrom.homingHardLimitExists
             homingHardLimitDistanceFromSensor = copyFrom.homingHardLimitDistanceFromSensor

      }
      
}