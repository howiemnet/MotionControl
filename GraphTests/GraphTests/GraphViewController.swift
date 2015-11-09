//
//  GraphViewController.swift
//  GraphTests
//
//  Created by h on 11/08/2015.
//  Copyright © 2015 h. All rights reserved.
//

import Cocoa

class GraphViewController: NSView {

    var color: NSColor = NSColor.blueColor()
    var lineWidth: CGFloat = 3
    
    override func drawRect(rect: NSRect) {
        
        let myPath = NSBezierPath()
        let myMin = NSPoint(x:bounds.minX, y:bounds.minY)
        let myMax = NSPoint(x:bounds.maxX, y:bounds.maxY)
        myPath.moveToPoint(myMin)
        
       // print("min: \(myMin), max: \(myMax)")
        
        
       for x in 0...Int(bounds.maxX) {
            myPath.lineToPoint(NSPoint(x: x, y: random() % Int(bounds.maxY)))
        }
        
        myPath.lineToPoint(myMax)
        
        myPath.lineWidth = lineWidth
        color.set()
        myPath.stroke()
        
        
    }
    
}
