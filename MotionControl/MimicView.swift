//
//  MimicView.swift
//  MimicDisplay
//
//  Created by h on 11/08/2015.
//  Copyright © 2015 h. All rights reserved.
//

import Cocoa
import Foundation

class MimicView: NSView {

    
    let sliderLength = 600.0
    
    
    var camSliderPos = 200.0 {
        didSet {
           setNeedsDisplayInRect(self.bounds)
        }
    }
    
    
    var camSliderPan = 0.0 {
        didSet {
            setNeedsDisplayInRect(self.bounds)
        }
    }
    
    
    
    private func bezierPathForCameraIcon(camPosition: CGPoint, camRotation: CGFloat) -> NSBezierPath {
        
        let iconSize = CGFloat(10.0)
        let iconRect = NSRect(x: -iconSize, y: -iconSize, width: iconSize * 2.0, height: iconSize * 2.0)
        
        
        
        let path = NSBezierPath(ovalInRect: iconRect)
        path.moveToPoint(NSPoint(x: 0, y: iconSize))
        path.lineToPoint(NSPoint(x: 0, y: 3 * iconSize))
        
        path.moveToPoint(NSPoint(x: -iconSize, y: 2 * iconSize))
        path.lineToPoint(NSPoint(x: 0, y: 3 * iconSize))
        path.lineToPoint(NSPoint(x: iconSize, y: 2 * iconSize))
        
        // now transform it:
        // rotate first:
        var myXform = NSAffineTransform()
        myXform.rotateByDegrees(CGFloat(camSliderPan))
        path.transformUsingAffineTransform(myXform)
        
        myXform = NSAffineTransform()
        
        myXform.translateXBy(camPosition.x, yBy: camPosition.y)
        
        path.transformUsingAffineTransform(myXform)
        
        
        
        return path
    }
    
    
    
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        let color = NSColor.blueColor()
        let lineWidth = CGFloat(3)
        
        let camPosOnSlider = CGPoint(x: camSliderPos, y: 50.0)// 100.0
        
        
        let myBezier = NSBezierPath()
        myBezier.moveToPoint(CGPoint(x: 0, y: 50))
        myBezier.lineToPoint(CGPoint(x: sliderLength, y: 50.0))
        
        color.set()
        myBezier.lineWidth = lineWidth
        myBezier.stroke()
        
        
        bezierPathForCameraIcon(camPosOnSlider, camRotation: CGFloat(camSliderPan)).stroke()
        
        // Drawing code here.
    }
    
}
