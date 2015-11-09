//
//  DeviceSetupCellView.swift
//  MotionControl
//
//  Created by h on 21/10/2015.
//  Copyright © 2015 slartibartfist. All rights reserved.
//

import Cocoa

class DeviceSetupCellView: NSTableCellView {
      
      @IBOutlet weak var devID: NSTextField!
      @IBOutlet weak var displayName: NSTextField!
      @IBOutlet weak var displayUnits: NSTextField!
      @IBOutlet weak var hide: NSButton!
      
      @IBOutlet weak var actuatorType: NSPopUpButton!
      @IBOutlet weak var actuatorMotion: NSPopUpButton!
      @IBOutlet weak var stepsPerUnit: NSTextField!
      @IBOutlet weak var canDisableMotor: NSButton!
      
      @IBOutlet weak var limitMin: NSTextField!
      @IBOutlet weak var limitMax: NSTextField!
      @IBOutlet weak var homePos: NSTextField!
      @IBOutlet weak var posFeedbackPossible: NSButton!
      
      @IBOutlet weak var speedOpt: NSTextField!
      @IBOutlet weak var speedMax: NSTextField!
      @IBOutlet weak var accelOpt: NSTextField!
      @IBOutlet weak var accelMax: NSTextField!
      @IBOutlet weak var jerkOpt: NSTextField!
      @IBOutlet weak var jerkMax: NSTextField!
      
      @IBOutlet weak var homingType: NSPopUpButton!
      @IBOutlet weak var homeSensorPos: NSTextField!
      @IBOutlet weak var homeSensorSize: NSTextField!
      
      override var objectValue:AnyObject? {
            didSet {
                  if let channelData = objectValue as? ChannelDataPersistent {
                        devID.integerValue = channelData.channelInterfaceID
                        displayName.stringValue = channelData.channelName
                        displayUnits.stringValue = channelData.displayUnits
                        hide.state = (channelData.hide) ? NSOnState : NSOffState
                        
                        
                        actuatorType.selectItemAtIndex(channelData.actuatorType.rawValue)
                        actuatorMotion.selectItemAtIndex(channelData.derivable.rawValue)
                        // actuatorMotion
                        stepsPerUnit.doubleValue = channelData.scale
                        limitMin.doubleValue = channelData.positionMinimum
                        limitMax.doubleValue = channelData.positionMaximum
                        homePos.doubleValue = channelData.homePosition
                        posFeedbackPossible.state = (channelData.canFeedBackPosition) ? NSOnState : NSOffState
                        
                        speedOpt.doubleValue = channelData.optimalSpeed
                        speedMax.doubleValue = channelData.maximumSpeed
                        accelOpt.doubleValue = channelData.optimalAcceleration
                        accelMax.doubleValue = channelData.maximumAcceleration
                        jerkOpt.doubleValue = channelData.optimalJerk
                        jerkMax.doubleValue = channelData.maximumJerk
                        
                        homingType.selectItemAtIndex(channelData.homingType.rawValue)
                        homeSensorPos.doubleValue = channelData.homeSwitchPosition
                        homeSensorSize.doubleValue = channelData.homingHardLimitDistanceFromSensor
                        
                   }
            }
      }
      
      // -------------------------------------------------------
      //
      //    ACTIONS!
      //
      // -------------------------------------------------------
      
      
      @IBAction func idChanged(sender: NSTextField) {
            if let channelData = objectValue as? ChannelDataPersistent {
                  channelData.channelInterfaceID = sender.integerValue
            }
      }
      
      @IBAction func displayNameChanged(sender: NSTextField) {
            if let channelData = objectValue as? ChannelDataPersistent {
                  channelData.channelName = sender.stringValue
            }
      }
      
      @IBAction func hideButton(sender: NSButton) {
            if let channelData = objectValue as? ChannelDataPersistent {
                  channelData.hide = (sender.state == NSOnState)
            }
      }
      
      
      @IBAction func displayUnitsChanged(sender: NSTextField) {
            if let channelData = objectValue as? ChannelDataPersistent {
                  channelData.displayUnits = sender.stringValue
            }
      }

      @IBAction func actuatorTypeChanged(sender: NSPopUpButton) {
            if let channelData = objectValue as? ChannelDataPersistent {
                  channelData.actuatorType = ActuatorType(rawValue: sender.selectedTag())!
            }
      }

      @IBAction func derivabilityChanged(sender: NSPopUpButton) {
            if let channelData = objectValue as? ChannelDataPersistent {
                  channelData.derivable = Derivability(rawValue: sender.selectedTag())!
            }
      }

      @IBAction func scaleChanged(sender: NSTextField) {
            if let channelData = objectValue as? ChannelDataPersistent {
                  channelData.scale = sender.doubleValue
            }
      }
      
      @IBAction func canDisableMotorChanged(sender: NSButton) {
            if let channelData = objectValue as? ChannelDataPersistent {
                  channelData.canDisableMotor = (sender.state == NSOnState)
            }
      }


      @IBAction func limitMinChanged(sender: NSTextField) {
            if let channelData = objectValue as? ChannelDataPersistent {
                  channelData.positionMinimum = sender.doubleValue
            }
      }

      @IBAction func limitMaxChanged(sender: NSTextField) {
            if let channelData = objectValue as? ChannelDataPersistent {
                  channelData.positionMaximum = sender.doubleValue
            }
      }

      @IBAction func homePosChanged(sender: NSTextField) {
            if let channelData = objectValue as? ChannelDataPersistent {
                  channelData.homePosition = sender.doubleValue
            }
      }

      @IBAction func positionFeedbackChanged(sender: NSButton) {
            if let channelData = objectValue as? ChannelDataPersistent {
                  channelData.canFeedBackPosition = (sender.state == NSOnState)
            }
      }

      
      
      @IBAction func speedOptChanged(sender: NSTextField) {
            if let channelData = objectValue as? ChannelDataPersistent {
                  channelData.optimalSpeed = sender.doubleValue
            }
      }

      @IBAction func speedMaxChanged(sender: NSTextField) {
            if let channelData = objectValue as? ChannelDataPersistent {
                  channelData.maximumSpeed = sender.doubleValue
            }
      }
      @IBAction func accelOpt(sender: NSTextField) {
            if let channelData = objectValue as? ChannelDataPersistent {
                  channelData.optimalAcceleration = sender.doubleValue
            }
      }
      @IBAction func accelMax(sender: NSTextField) {
            if let channelData = objectValue as? ChannelDataPersistent {
                  channelData.maximumAcceleration = sender.doubleValue
            }
      }
      @IBAction func jerkOpt(sender: NSTextField) {
            if let channelData = objectValue as? ChannelDataPersistent {
                  channelData.optimalJerk = sender.doubleValue
            }
      }
      @IBAction func jerkMax(sender: NSTextField) {
            if let channelData = objectValue as? ChannelDataPersistent {
                  channelData.maximumJerk = sender.doubleValue
            }
      }

      
      @IBAction func homeTypeChanged(sender: NSPopUpButton) {
            if let channelData = objectValue as? ChannelDataPersistent {
                  channelData.homingType = HomingType(rawValue: sender.selectedTag())!
            }
      }

      
      @IBAction func homeSwitchPos(sender: NSTextField) {
            if let channelData = objectValue as? ChannelDataPersistent {
                  channelData.homeSwitchPosition = sender.doubleValue
            }
      }
      @IBAction func homeSwitchSize(sender: NSTextField) {
            if let channelData = objectValue as? ChannelDataPersistent {
                  channelData.homingHardLimitDistanceFromSensor = sender.doubleValue
            }
      }

      
      
}
