//
//  SequencerTableCellView.swift
//  MotionControl
//
//  Created by h on 27/07/2015.
//  Copyright © 2015 slartibartfist. All rights reserved.
//

import Cocoa

class SequencerTableCellView: NSTableCellView {

    @IBOutlet weak var cueName: NSTextField!
    @IBOutlet weak var cueNumber: NSTextField!

    @IBOutlet weak var duration: NSTextField!
    @IBOutlet weak var durationStepper: NSStepper!
    @IBOutlet weak var easeInType: NSPopUpButton!
    @IBOutlet weak var easeInDuration: NSTextField!
    @IBOutlet weak var easeInDurationStepper: NSStepper!
    
    @IBOutlet weak var useSameEaseInOut: NSButton!
    @IBOutlet weak var easeOutType: NSPopUpButton!
    @IBOutlet weak var easeOutDuration: NSTextField!
    @IBOutlet weak var easeOutDurationStepper: NSStepper!
    @IBOutlet weak var subjectTriangulated: NSTextField!
    @IBOutlet weak var focusDistance: NSTextField!
    
    var cueNum: Int = 0
    var keyframe: Keyframe?

    
    
   // @IBOutlet weak var travelDistance: NSTextField!
    
    
    func populateThePopups() {
        // Add an array of items to the list
     //   var myChanNames = [String]()
     //   for channel in executiveController.channelData {
      //      myChanNames.append(channel.channelName)
      //  }
//        dominantChannelPopup.removeAllItems()
//        dominantChannelPopup.addItemsWithTitles(myChanNames)
    }

    
    @IBAction func cueGoButton(sender: NSButton) {
        if let kf = objectValue as? Keyframe {
            kf.sequenceController.goToCue(kf.cueNum)
        }
    }
    
    
    
    weak var sequenceController: SequenceController?
    
    override var objectValue:AnyObject? {
        didSet {
            if let kf = objectValue as? Keyframe {
                keyframe = kf
                cueNum = keyframe!.cueNum
                cueName.stringValue = keyframe!.cueName
                cueNumber.integerValue = cueNum
                updateUI()
            }
        }
    }
    

    @IBAction func cueNameEdit(sender: NSTextField) {
        if let myData = objectValue as? Keyframe {
            myData.cueName = sender.stringValue
            myData.sequenceController.updateUI()
        }
    }
    
    @IBAction func durationChanged(sender: NSTextField) {
        if let kf = objectValue as? Keyframe {
            kf.duration = validateDuration(sender.doubleValue)
            updateUI()
        }
    }
    
    @IBAction func durationStepper(sender: NSStepper) {
        if let kf = objectValue as? Keyframe {
            kf.duration = validateDuration((kf.duration) + Double(sender.integerValue))
            durationStepper.integerValue = 0
        }
        updateUI()
        
    }
    
    func validateDuration(theDurationToTest: Double) -> Double {
        var theDuration = theDurationToTest
        theDuration = max(theDuration, 1.0)
        theDuration = max(theDuration, keyframe!.easeInDuration + keyframe!.easeOutDuration)
        
        
        return theDuration
    }
    
    
    func validateEaseInDuration(theDurationToTest: Double) -> Double {
        var theDuration = theDurationToTest
        theDuration = max(theDuration, 0.5)
        if (keyframe!.useSameEaseForInAndOut) {
            theDuration = min(theDuration, (keyframe!.duration - theDuration))
        } else {
            theDuration = min(theDuration, keyframe!.duration - keyframe!.easeOutDuration)
        }
        return theDuration
    }
    
    
    func validateEaseOutDuration(theDurationToTest: Double) -> Double {
        var theDuration = theDurationToTest
        theDuration = max(theDuration, 0.5)
        theDuration = min(theDuration, keyframe!.duration - keyframe!.easeInDuration)
        return theDuration
    }
    
    
    
    @IBAction func useSameEaseInOut(sender: NSButton) {
        
        keyframe?.useSameEaseForInAndOut = (sender.state == NSOnState)
        updateUI()
        
    }
    
    
    @IBAction func testStepper(sender: NSStepper) {
        Swift.print ("STEPPER")
    }
    
    @IBAction func easeInType(sender: NSPopUpButtonCell) {
    }
    
    @IBAction func easeInDurationChanged(sender: NSTextField) {
        keyframe?.easeInDuration = validateEaseInDuration(sender.doubleValue)
        if (keyframe!.useSameEaseForInAndOut) {
            keyframe!.easeOutDuration = keyframe!.easeInDuration
        }
    }
    
    @IBAction func easeInDurationStepper(sender: NSStepper) {
        keyframe!.easeInDuration = validateEaseInDuration(keyframe!.easeInDuration + Double(sender.integerValue))
        if (keyframe!.useSameEaseForInAndOut) {
            keyframe!.easeOutDuration = keyframe!.easeInDuration
        }
        easeInDurationStepper.integerValue = 0
        updateUI()
        
    }
    
    @IBAction func easeOutDurationChanged(sender: NSTextField) {
        keyframe!.easeOutDuration = sender.doubleValue
    }
    
    @IBAction func easeOutDurationStepper(sender: NSStepper) {
        keyframe!.easeOutDuration += Double(sender.integerValue)
        if (keyframe!.easeOutDuration < 0) {
            keyframe!.easeOutDuration = 0
        }
        easeOutDurationStepper.integerValue = 0
        updateUI()
    }
    

    @IBOutlet weak var triangulationEnabled: NSButton!
    
    @IBAction func triangulationEnabled(sender: NSButton) {
        if sender.state == NSOnState {
            keyframe!.triangulationEnabled = true
        } else {
            keyframe!.triangulationEnabled = false
        }
    }
    
    
    func updateUI() {
        if let kf = objectValue as? Keyframe {
            //travelDistance.doubleValue = keyframe!.distance
            cueName.stringValue = kf.cueName
            duration.stringValue = String(kf.duration)
            useSameEaseInOut.state = (kf.useSameEaseForInAndOut) ? NSOnState : NSOffState
            //dominantChannelPopup.selectItemAtIndex(keyframe!.dominantChannel)
            
            if (useSameEaseInOut.state == NSOffState) {
                easeOutType.enabled = true;
                easeOutDuration.enabled = true;
            } else {
                easeOutType.enabled = false;
                easeOutDuration.enabled = false;
                
            }
            
            easeInDuration.doubleValue = kf.easeInDuration
            easeOutDuration.doubleValue = kf.easeOutDuration
            
            if (kf.subjectTriangulated) {
                triangulationEnabled.enabled = true
                subjectTriangulated.stringValue = "X: \(kf.subjectPosition.x), Y: \(kf.subjectPosition.x)"
                focusDistance.doubleValue = kf.subjectDistanceAtStart
            } else {
                triangulationEnabled.enabled = false
                
            }
            
            
            
            if (kf.triangulationEnabled) {
                triangulationEnabled.state = NSOnState
            } else {
                triangulationEnabled.state = NSOffState
            }
            
            
        }
    }

    
    
    
    
    
    
}
