//
//  ChannelLibrary.swift
//  MotionControl
//
//  Created by h on 15/10/2015.
//  Copyright © 2015 slartibartfist. All rights reserved.
//

import Foundation

typealias ChannelDict = NSDictionary //[String:AnyObject]


class ChannelLibrary {
    
    var channelDataPersistentArray : [ChannelDataPersistent]
    
    
    init() {
        print ("ChannelLibrary Init: Load library")
        channelDataPersistentArray = [ChannelDataPersistent]()
        //setUpChannelsTheUglyWay()
        loadLibrary()
    }
    
    func getAllChannelsPersistentData() -> [ChannelDataPersistent] {
        var myArrayCopy = [ChannelDataPersistent]()
        for channel in channelDataPersistentArray {
            let theCopy = ChannelDataPersistent(copyFrom: channel)
            myArrayCopy.append(theCopy)
        }
        return myArrayCopy
    }
    
    func setAllChannelsPersistentData(data: [ChannelDataPersistent]) {
        channelDataPersistentArray = data
        saveLibrary()
    }
    
    func getPersistentDataForChannelID(channelID: Int) -> ChannelDataPersistent? {
        for channel in channelDataPersistentArray {
            if channel.channelInterfaceID == channelID {
                return channel
            }
        }
        return (nil)
    }
    
    
    func loadLibrary() {
        setUpChannelsTheUglyWay()
        print("Load library code will go here")
        
        let fileManager = NSFileManager.defaultManager()
        var directoryURL = NSURL()
        do {
            directoryURL = try fileManager.URLForDirectory(.DocumentDirectory, inDomain:.UserDomainMask, appropriateForURL:nil, create:false)
        } catch {
            print ("there wuz an error generating the library url")
        }
        //let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        //let documentsDirectory = paths[0] as! NSURL
        let pathURL = NSURL(string: "DeviceChannelLibrary.plist", relativeToURL: directoryURL)
        //check if file exists
        if(!fileManager.fileExistsAtPath((pathURL?.path)!)) {
            // If it doesn't, copy it from the default file in the Bundle
            
            print("No library found.")
        } else {
            print("Library found... loading...")
            let resultArray = NSArray(contentsOfURL: pathURL!)
            print ("Loaded \(resultArray!.count) devices")
            loadChannelDataFromDictionaryArray(resultArray!)
            
        }
    }
    
    func saveLibrary() {
        print ("Saving library...")
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0) as! NSString
        let path = documentsDirectory.stringByAppendingPathComponent("DeviceChannelLibrary.plist")
        //var dict: NSMutableDictionary = ["XInitializerItem": "DoNotEverChangeMe"]
        //saving values
        //dict.setObject(ChannelNameKeyID, forKey: ChannelNameKey)
        //dict.setObject(ChannelIDKeyID, forKey: ChannelIDKey)
        //...
        //writing to GameData.plist
        let theArray = getChannelDictionaries() //as NSMutableArray
        theArray.writeToFile(path, atomically: false)
        
    }
    
    func getChannelDictionaries() -> NSArray { //[NSDictionary] {
        var dictionaryArray = [ChannelDict]()
        for channel in channelDataPersistentArray {
            let channelDict = getDictionaryFromPersistentData(channel)
            dictionaryArray.append(channelDict)
        }
        return dictionaryArray
    }
    
    func loadChannelDataFromDictionaryArray(theDictionaryArray: NSArray) {
        channelDataPersistentArray = []
        //if let myDict = theDictionaryArray {
        for entry in theDictionaryArray {
            channelDataPersistentArray.append(getPersistentDataFromDictionary(entry as! ChannelDict))
        }
        // }
    }
    
    
    func getDictionaryFromPersistentData(channelData: ChannelDataPersistent) -> ChannelDict {
        let dict = NSMutableDictionary()
        dict.setValue(channelData.channelInterfaceID, forKey: "channelInterfaceID")
        dict.setValue(channelData.channelName, forKey: "channelName")
        dict.setValue(channelData.hide, forKey: "hide")
        
        dict.setValue(channelData.actuatorType.rawValue, forKey: "actuatorType")
        dict.setValue(channelData.derivable.rawValue, forKey: "derivable")
        dict.setValue(channelData.canFeedBackPosition, forKey: "canFeedBackPosition")
        dict.setValue(channelData.canDisableMotor, forKey: "canDisableMotor")
        
        dict.setValue(channelData.displayUnits, forKey: "displayUnits")
        dict.setValue(channelData.hardwareTranslation.rawValue, forKey: "hardwareTranslation")
        dict.setValue(channelData.scale, forKey: "scale")
        
        
        dict.setValue(channelData.positionMinimum, forKey: "positionMinimum")
        dict.setValue(channelData.positionMaximum, forKey: "positionMaximum")
        dict.setValue(channelData.positionNudgeSmall, forKey: "positionNudgeSmall")
        dict.setValue(channelData.positionNudgeLarge, forKey: "positionNudgeSmall")
        
        dict.setValue(channelData.optimalSpeed, forKey: "optimalSpeed")
        dict.setValue(channelData.optimalAcceleration, forKey: "optimalAcceleration")
        dict.setValue(channelData.optimalJerk, forKey: "optimalJerk")
        dict.setValue(channelData.maximumSpeed, forKey: "maximumSpeed")
        dict.setValue(channelData.maximumAcceleration, forKey: "maximumAcceleration")
        dict.setValue(channelData.maximumJerk, forKey: "maximumJerk")
        
        dict.setValue(channelData.homingType.rawValue, forKey: "homingType")
        dict.setValue(channelData.homePosition, forKey: "homePosition")
        dict.setValue(channelData.homeSwitchPosition, forKey: "homeSwitchPosition")
        dict.setValue(channelData.homingHardLimitExists, forKey: "homingHardLimitExists")
        dict.setValue(channelData.homingHardLimitDistanceFromSensor, forKey: "homingHardLimitDistanceFromSensor")
        return dict
    }
    
    func getPersistentDataFromDictionary(dict: ChannelDict) -> ChannelDataPersistent {
        let channelData = ChannelDataPersistent()
        channelData.channelInterfaceID = dict["channelInterfaceID"] as? Int ?? -1
        channelData.channelName = dict["channelName"] as? String ?? "MSLIDER"
        channelData.hide = dict["hide"] as? Bool ?? false
        
        // actuator information
        channelData.actuatorType = ActuatorType(rawValue: (dict["actuatorType"] as? Int)!) ?? ActuatorType.Linear
        channelData.derivable = Derivability(rawValue: (dict["derivable"] as? Int)!) ?? Derivability.None
        channelData.canFeedBackPosition = dict["canFeedBackPosition"] as? Bool ?? false
        channelData.canDisableMotor = dict["canDisableMotor"] as? Bool ?? false
        
        // scales
        channelData.displayUnits = dict["displayUnits"] as? String ?? "mm"
        channelData.hardwareTranslation = HardwareTranslationType(rawValue: (dict["hardwareTranslation"] as? Int)!) ?? HardwareTranslationType.StepperScale
        channelData.scale =  dict["scale"] as? Double ?? 80.0                   // this is pulses / steps per displayUnit
        
        // limits
        channelData.positionMinimum = dict["positionMinimum"] as? Double ?? 0.0
        channelData.positionMaximum = dict["positionMaximum"] as? Double ?? 300.0
        channelData.positionNudgeSmall = dict["positionNudgeSmall"] as? Double ?? 0.0
        channelData.positionNudgeLarge = dict["positionNudgeLarge"] as? Double ?? 0.0
        
        // physics limits
        channelData.optimalSpeed = dict["optimalSpeed"] as? Double ?? 1.0
        channelData.optimalAcceleration = dict["optimalAcceleration"] as? Double ?? 0.2
        channelData.optimalJerk = dict["optimalJerk"] as? Double ?? 0.0
        channelData.maximumSpeed = dict["maximumSpeed"] as? Double ?? 2.0
        channelData.maximumAcceleration = dict["maximumAcceleration"] as? Double ?? 4.0
        channelData.maximumJerk = dict["maximumJerk"] as? Double ?? 0.0
        
        // homing
        channelData.homingType = HomingType(rawValue: (dict["homingType"] as? Int)!) ?? HomingType.HuntForHomeSwitch
        channelData.homePosition = dict["homePosition"] as? Double ?? 0.0
        channelData.homeSwitchPosition = dict["homeSwitchPosition"] as? Double ?? 0.0
        channelData.homingHardLimitExists = dict["homingHardLimitExists"] as? Bool ?? false
        channelData.homingHardLimitDistanceFromSensor = dict["homingHardLimitDistanceFromSensor"] as? Double ?? 0.0
        
        return channelData
    }
    
    
    func setUpChannelsTheUglyWay() {
        
        // ------------------------------ //
        //
        //      Macro slider
        //
        // ------------------------------ //
        
        var channelData = ChannelDataPersistent()
        channelData.channelInterfaceID = 5
        channelData.channelName = "MSLIDER"
        
        // actuator information
        channelData.actuatorType = .Linear
        channelData.derivable = .None
        channelData.canFeedBackPosition = false
        channelData.canDisableMotor = false
        
        // scales
        channelData.displayUnits = "mm"
        channelData.hardwareTranslation = .StepperScale
        channelData.scale = 80                   // this is pulses / steps per displayUnit
        
        // limits
        channelData.positionMinimum = 0.0
        channelData.positionMaximum = 300.0
        channelData.positionNudgeSmall = 0.0
        channelData.positionNudgeLarge = 0.0
        
        // physics limits
        channelData.optimalSpeed = 1.0
        channelData.optimalAcceleration = 0.2
        channelData.optimalJerk = 0.0
        channelData.maximumSpeed = 2.0
        channelData.maximumAcceleration = 4.0
        channelData.maximumJerk = 0.0
        
        // homing
        channelData.homingType = .HuntForHomeSwitch
        channelData.homePosition = 0.0
        channelData.homeSwitchPosition = 0.0
        channelData.homingHardLimitExists = false
        channelData.homingHardLimitDistanceFromSensor = 0.0
        
        channelDataPersistentArray.append(channelData)
        
        
        
        
        channelData = ChannelDataPersistent()
        channelData.channelInterfaceID = 7
        channelData.channelName = "MTURN"
        
        // actuator information
        channelData.actuatorType = .Rotational
        channelData.derivable = .None
        channelData.canFeedBackPosition = false
        channelData.canDisableMotor = false
        
        // scales
        channelData.displayUnits = "deg"
        channelData.hardwareTranslation = .StepperScale
        channelData.scale = 80                 // this is pulses / steps per displayUnit
        
        // limits
        channelData.positionMinimum = -180.0
        channelData.positionMaximum = 180.0
        channelData.positionNudgeSmall = 0.0
        channelData.positionNudgeLarge = 0.0
        
        // physics limits
        channelData.optimalSpeed = 1.0
        channelData.optimalAcceleration = 0.2
        channelData.optimalJerk = 0.0
        channelData.maximumSpeed = 2.0
        channelData.maximumAcceleration = 4.0
        channelData.maximumJerk = 0.0
        
        // homing
        channelData.homingType = .HuntForHomeSwitch
        channelData.homePosition = 0.0
        channelData.homeSwitchPosition = 0.0
        channelData.homingHardLimitExists = false
        channelData.homingHardLimitDistanceFromSensor = 0.0
        
        channelDataPersistentArray.append(channelData)
        
        
        
        
        
        
        
        
        /*
        
        channelData.channelName = "MACROSLIDER"
        channelData.channelInterfaceID = 0
        
        channelData.positionMinimum = -180.0
        channelData.positionMaximum = 180.0
        channelData.positionNudgeSmall = 20.0
        
        channelData.homePosition = 0.0
        channelData.scale = 94   // 93.75 really
        channelData.actuatorType = .Rotational
        channelData.derivable = .Lookat
        channelData.maximumSpeed = 3.0
        channelData.maximumAcceleration = 0.3
        
        channelData.displayUnits = "°"
        
        channelData.homingHardLimitDistanceFromSensor = 5.0
        channelData.homingHardLimitExists = true
        channelData.homeSwitchPosition = -2.5
        
        
        
        
        
        
        
        channel = Channel(execController: self)
        
        channel.channelIndex = 1
        
        channel.positionMinimum = 0.0
        channel.positionMaximum = 1000.0
        channel.homePosition = 0.0
        channel.positionNudgeSmall = 10.0
        
        channel.absoluteMaximumSpeed = 15.0
        channel.absoluteMaximumAcceleration = 3.0
        channel.scale = 80
        
        channel.maximumSpeed = 3.0
        channel.maximumAcceleration = 0.2
        
        channel.actuatorType = .Linear
        channel.derivable = .None
        channel.hardwareInterfacePortname = "/dev/cu.usbmodem1131621"
        
        newInterface = SimulateSerialHandler()
        newInterface.myChannel = channel //self
        newInterface.channelIndex = 1
        newInterface.path = channel.hardwareInterfacePortname
        
        newInterface.executiveController = self
        
        channel.hardwareInterface = newInterface
        
        channel.positionActual = 0.0
        channel.positionDesired = 0.0
        channel.channelName = "SLIDER"
        channel.displayUnits = "mm"
        
        channel.homingAcceleration = 1.0
        channel.homingHardLimitDistanceFromSensor = 10.0
        channel.homingHardLimitExists = true
        channel.homingEnabled = true
        channel.homeSwitchPosition = -1.0
        
        
        channelData.append(channel)
        
        
        
        
        
        channel = Channel(execController: self)
        
        channel.channelIndex = 1
        
        channel.positionMinimum = 0.0
        channel.positionMaximum = 1000.0
        channel.homePosition = 0.0
        channel.positionNudgeSmall = 10.0
        
        channel.absoluteMaximumSpeed = 15.0
        channel.absoluteMaximumAcceleration = 3.0
        channel.scale = 80
        
        channel.maximumSpeed = 3.0
        channel.maximumAcceleration = 0.2
        
        channel.actuatorType = .Linear
        channel.derivable = .None
        channel.hardwareInterfacePortname = "/dev/cu.usbmodem1131261"
        
        newInterface = SimulateSerialHandler()
        newInterface.myChannel = channel //self
        newInterface.channelIndex = 1
        newInterface.path = channel.hardwareInterfacePortname
        
        newInterface.executiveController = self
        
        channel.hardwareInterface = newInterface
        
        channel.positionActual = 0.0
        channel.positionDesired = 0.0
        channel.channelName = "MACRO"
        channel.displayUnits = "mm"
        
        channel.homingAcceleration = 1.0
        channel.homingHardLimitDistanceFromSensor = 10.0
        channel.homingHardLimitExists = true
        channel.homingEnabled = true
        channel.homeSwitchPosition = -1.0
        
        
        channelData.append(channel)
        
        
        
        
        
        
        channel = Channel(execController: self)
        
        channel.channelIndex = 2
        
        channel.positionMinimum = 193.0
        channel.positionMaximum = 347.0
        channel.homePosition = 193.0
        
        // channel.absoluteMaximumSpeed = 40.0
        // channel.absoluteMaximumAcceleration = 40.0
        channel.scale = 1
        
        channel.maximumSpeed = 20.0
        channel.maximumAcceleration = 10.0
        channel.actuatorType = .LensAF
        channel.derivable = .Focus
        channel.hardwareTranslation = .LensScale
        
        
        channel.hardwareInterfacePortname = "/dev/cu.usbserial-A100QBS2"
        
        newInterface = SimulateSerialHandler()
        newInterface.myChannel = channel //self
        newInterface.channelIndex = 2
        newInterface.path = channel.hardwareInterfacePortname
        
        newInterface.executiveController = self
        
        channel.hardwareInterface = newInterface
        
        channel.positionActual = 193.0
        channel.positionDesired = 193.0
        channel.channelName = "LENS"
        channel.displayUnits = "mm"
        
        channelData.append(channel)
        
        
        channel = Channel(execController: self)
        
        channel.channelIndex = 3
        channel.positionActual = 0.0
        channel.positionMinimum = -180.0
        channel.positionMaximum = 180.0
        channel.positionNudgeSmall = 20.0
        
        channel.homePosition = 0.0
        channel.scale = 320
        channel.actuatorType = .Rotational
        channel.absoluteMaximumAcceleration = 2.0
        channel.absoluteMaximumSpeed = 8.0
        channel.derivable = .None
        channel.maximumSpeed = 2.0
        channel.maximumAcceleration = 0.2
        
        channel.positionDesired = 0.0
        channel.channelName = "TILT"
        channel.displayUnits = "°"
        channel.hardwareInterfacePortname = "/dev/cu.usbmodem1131111"
        
        newInterface = SimulateSerialHandler()
        newInterface.myChannel = channel
        newInterface.channelIndex = 3
        newInterface.path = channel.hardwareInterfacePortname
        newInterface.executiveController = self
        channel.hardwareInterface = newInterface
        
        
        channel.homingAcceleration = 1.0
        channel.homingHardLimitDistanceFromSensor = 5.0
        channel.homingHardLimitExists = true
        channel.homingEnabled = true
        channel.homeSwitchPosition = -2.5
        
        
        
        channelData.append(channel)
        */
        
    }
    
}