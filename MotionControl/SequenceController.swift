//
//  SequenceController.swift
//  MotionControl
//
//  Created by h on 28/07/2015.
//  Copyright © 2015 slartibartfist. All rights reserved.
//

import Cocoa


struct Position {
    var x = 0.0
    var y = 0.0
}



class SequenceController : NSObject, NSTableViewDelegate, NSTableViewDataSource {
    
    var keyframeList = [Keyframe]()

    var executiveController: ExecutiveController?

    @IBOutlet weak var sequencerTable: NSTableView!
    @IBOutlet weak var removeCueButton: NSButton!
    
    override init() {
        super.init()
        //sequencerTable!.sequen
    }
 
    
    var viableSequenceAvailable: Bool {
        get {
            var theRetValue = false
            if (keyframeList.count > 1) && (self.sequencerTable.selectedRow < (keyframeList.count - 1)) && (self.sequencerTable.selectedRow > -1) {
                theRetValue = true
            }
            return theRetValue
        }
    }
    
    var currentCue: Int {
        get {
            return sequencerTable.selectedRow
        }
    }

    
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return keyframeList[row]
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        
       
         return keyframeList.count
    }
    
    // Not sure this is the ideal way to do this.
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 45.0
    }
    

    @IBAction func addCue(sender: NSButton) {
        let theKeyframe = Keyframe(seqCnt: self)
        theKeyframe.channelPositions = executiveController!.getCurrentChannelPositions()
        theKeyframe.useSameEaseForInAndOut = true
        theKeyframe.duration = 5.0
        theKeyframe.easeInType = .Linear
        theKeyframe.easeInDuration = 1.0
        theKeyframe.easeOutType = .Linear
        theKeyframe.easeOutDuration = 1.0
        theKeyframe.dominantChannel = 1
        theKeyframe.cueNum = keyframeList.count
        
        var didTriangulate = false
        
       // print("Checking for triangulatable subject")
        
        if (false) { //(keyframeList.count > 0) {
       /*     let prevKeyframe = keyframeList[keyframeList.count - 1]
            var angle1 = prevKeyframe.channelPositions.positions[0]
            var angle2 = theKeyframe.channelPositions.positions[0]
            let distance = theKeyframe.channelPositions.positions[1] - prevKeyframe.channelPositions.positions[1]
            
            print("Distance: \(distance)")
            prevKeyframe.distance = distance
            
            if distance == 0 {
                // only panning or changing focus
                
            } else {
                if distance < 0 {
                    // moving backwards, so reverse the angles
                    print ("Backwards")
                    let tempAngle = angle2
                    angle2 = angle1
                    angle1 = tempAngle
                }
                
                // check if either angle is +/-90, in which case can't triangulate
                
                if abs(angle1) == 90 || abs(angle2) == 90 {
                    print ("Can't triangulate as at least one angle is 90deg")
                    
                    if angle1 == angle2 {
                        print ("Could be a push in or out shot, though...")
                    
                        print ("Taking focus at start and calculating from there...")
                        if ( (angle1 == 90.0) == (distance > 0.0) ) {
                            // moving in
                            theKeyframe.channelPositions.positions[2] = prevKeyframe.channelPositions.positions[2] - abs(distance)
                        } else {
                            theKeyframe.channelPositions.positions[2] = prevKeyframe.channelPositions.positions[2] + abs(distance)
                        }
                    
                    
                    }
                    
                } else {
                    
                    // check if angles are obtuse
                    
                    
                    var anglesTotal = 90.0 - angle1
                    anglesTotal += ( 90.0 + angle2 )
                    
                    
                    
                    
                    
                    if (anglesTotal) >= 180.0 {
                        print ("angles add up to > 180")
                    
                    } else {
                        
                        // let's triangulate and zoom in and rotate, Grissom
                        
                        let subjectPos = triangulatePositionFromAngles(angle1, theta2: angle2)
                        
                        // triangulation goes in the previous keyframe, not this one!!!!
                        prevKeyframe.subjectTriangulated = true
                        prevKeyframe.triangulationEnabled = true
                        
                        let subX = subjectPos.x * abs(distance)
                        let subY = subjectPos.y * abs(distance)
                        
                        prevKeyframe.subjectPosition = Position(x: subX, y: subY)
                        
                        var theOpp = subX - prevKeyframe.channelPositions.positions[1]
                        var focDistance = sqrt( (subY * subY) + (theOpp * theOpp) )

                        prevKeyframe.subjectDistanceAtStart = focDistance
                        
                        theOpp = subX - theKeyframe.channelPositions.positions[1]
                        focDistance = sqrt( (subY * subY) + (theOpp * theOpp) )
                        
                        prevKeyframe.subjectDistanceAtEnd = focDistance
                        
                        
                        if distance > 0 {
                            prevKeyframe.subjectPosition.x  += prevKeyframe.channelPositions.positions[1]
                        } else {
                            prevKeyframe.subjectPosition.x  += theKeyframe.channelPositions.positions[1]
                        }
                        
                        
                        
                        
                        print ("Subject at \(prevKeyframe.subjectPosition.x), \(prevKeyframe.subjectPosition.y)")
                        print ("Focus distance at start: \(prevKeyframe.subjectDistanceAtStart), and at end: \(prevKeyframe.subjectDistanceAtEnd)")
                        
                        prevKeyframe.channelPositions.positions[2] = prevKeyframe.subjectDistanceAtStart
                        theKeyframe.channelPositions.positions[2] = prevKeyframe.subjectDistanceAtEnd
                        didTriangulate = true
                        
                    }
                    
                }
                
            }
            */
        }
        
        
        keyframeList.append(theKeyframe)
        print ("Adding a new one")
        
        
        
        let newRowIndex = keyframeList.count - 1
        sequencerTable.insertRowsAtIndexes(NSIndexSet (index: newRowIndex), withAnimation: NSTableViewAnimationOptions.EffectGap)
        sequencerTable.selectRowIndexes(NSIndexSet(index: newRowIndex), byExtendingSelection:false)
        sequencerTable.scrollRowToVisible(newRowIndex)
        if didTriangulate {
            sequencerTable.reloadDataForRowIndexes(NSIndexSet(index: newRowIndex-1), columnIndexes: NSIndexSet(index: 0))
        }
        //updateUI()
    }
  
    
    let degToRad = 180.0 / 3.1415926
    let epsilon = 0.000001
    
    
    func triangulatePositionFromAngles(theta1: Double, theta2: Double) -> Position {
        
        
        let t1 = 1 / tan(theta1 / degToRad)
        let t2 = 1 / tan(theta2 / degToRad)
        var x = 0.0
        var y = 0.0
        
        // special cases:
        if (abs(theta1) < epsilon) {
            x = 0.0
            y = -(t2)
        } else if (abs(theta2) < epsilon) {
            x = 1.0
            y = t1
        } else {
            x = t2 / (t2 - t1)
            y = (t1 * t2) / (t2 - t1)
        }
        return Position(x: x, y: y)
        
    }
    
    
    
    
    
    
    
    @IBAction func removeCue(sender: NSButton) {
            keyframeList.removeAtIndex(self.sequencerTable.selectedRow)
            self.sequencerTable.removeRowsAtIndexes(NSIndexSet(index:self.sequencerTable.selectedRow), withAnimation: NSTableViewAnimationOptions.SlideRight)
            
            // 4. Clear detail info
//            updateDetailInfo(nil)

    }
    
 
    @IBAction func moveCueUpButton(sender: AnyObject) {
    }
    
    @IBAction func moveCueDownButton(sender: AnyObject) {
    }
    
    func updateUI() {
        print ("Keyframe list: \(keyframeList)")
        sequencerTable.reloadData() // . setNeedsDisplay()
        //keyframeDetail.updateUI()
    }
    
    
    @IBAction func sequencerTableAction(sender: AnyObject) {
       // if let theTable = sender as? NSTab
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
       print ("Selection changed: \(sequencerTable.selectedRow)")
        if sequencerTable.selectedRow < 0 {
            removeCueButton.enabled = false
        } else {
            removeCueButton.enabled = true
           // keyframeDetail.keyframe = keyframeList[sequencerTable.selectedRow]
            
        }
        
        // handle the cue up and down buttons
        if (sequencerTable.selectedRow >= 0) && (keyframeList.count > 1) {
            if sequencerTable.selectedRow < (keyframeList.count - 1) {
               // moveCueDownButton.enabled = true
            } else {
              //  moveCueDownButton.enabled = false
            }
            if sequencerTable.selectedRow > 0 {
               // moveCueUpButton.enabled = true
            } else {
               // moveCueUpButton.enabled = false
            }
            
        } else {
          //  moveCueDownButton.enabled = false
          //  moveCueUpButton.enabled = false
        }
        
    }
    
    func goToCue(cueNum: Int) {
        executiveController?.setCurrentChannelPositions(keyframeList[cueNum].channelPositions)
    }
    
    
    
}

// comments
