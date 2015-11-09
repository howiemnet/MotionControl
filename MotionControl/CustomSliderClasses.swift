//
//  BigSlider.swift
//  MotionControl
//
//  Created by h on 11/08/2015.
//  Copyright © 2015 slartibartfist. All rights reserved.
//

import Cocoa


class BigSlider: NSSliderCell {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func drawBarInside(aRect: NSRect, flipped: Bool) {
        var rect = aRect
        rect.size.height = CGFloat(5)
        let barRadius = CGFloat(2)
        
        
        
        var bg = NSBezierPath(roundedRect: rect, xRadius: barRadius, yRadius: barRadius)
        NSColor.blackColor().setFill()
        bg.fill()
        
        var nRect = rect
      nRect.origin = CGPoint(x: rect.origin.x, y: rect.origin.y+1)
      //offsetInPlace(dx: 0, dy: 1)
        nRect.size.height = CGFloat(4.0)
        
        bg = NSBezierPath(roundedRect: nRect, xRadius: 1.5, yRadius: 1.5)
        let myCol = NSColor(calibratedHue: 0.0, saturation: 0.0, brightness: 0.15, alpha: 1.0)
        myCol.setFill()
        bg.fill()
        
    }
    
    
}

class TinySlider: NSSliderCell {
    
    let myKnobImage = NSImage(named: "glowThumb")
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawBarInside(aRect: NSRect, flipped: Bool) {
        var rect = aRect
        rect.size.height = CGFloat(5)
        let barRadius = CGFloat(2.5)
        let bg = NSBezierPath(roundedRect: rect, xRadius: barRadius, yRadius: barRadius)
        NSColor(calibratedHue: 0.0, saturation: 0.0, brightness: 0.15, alpha: 1.0).setFill()
        bg.fill()
    }
    
    
    
    override func drawKnob(dRect: NSRect) {
        // nothing, ha!
        let myRect = dRect
        //myRect.size.height = myKnobImage!.size.height
        //myRect.offset(dx:0, dy:0)
        myKnobImage!.drawInRect(myRect)
    }
    
}

class MicroSlider: NSSliderCell {
    
    let myKnobImage = NSImage(named: "tinySliderThumb")
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawBarInside(aRect: NSRect, flipped: Bool) {
        var rect = aRect
        rect.size.height = CGFloat(5)
        let barRadius = CGFloat(2)
        
        //let indicatorWidth = CGFloat(15)
        
        
        var bg = NSBezierPath(roundedRect: rect, xRadius: barRadius, yRadius: barRadius)
        NSColor.blackColor().setFill()
        bg.fill()
        
        var nRect = rect
      //nRect.offsetInPlace(dx: 0, dy: 1)
      nRect.origin = CGPoint(x: rect.origin.x, y: rect.origin.y+1)
      nRect.size.height = CGFloat(4.0)
        
        bg = NSBezierPath(roundedRect: nRect, xRadius: 1.5, yRadius: 1.5)
        let myCol = NSColor(calibratedHue: 0.0, saturation: 0.0, brightness: 0.2, alpha: 1.0)
        myCol.setFill()
        bg.fill()
        
        /*rect = aRect
        
        let value = CGFloat((self.doubleValue - self.minValue) / (self.maxValue - self.minValue))
        let leftEnd = CGFloat(value * (self.controlView!.frame.size.width - (8 + indicatorWidth)))
        rect.offset(dx: leftEnd, dy: 0)
        
        rect.size.width = indicatorWidth
        bg = NSBezierPath(roundedRect: rect, xRadius: barRadius, yRadius: barRadius)
        NSColor.orangeColor().setFill()
        bg.fill()*/
    }
    
    override func drawKnob(dRect: NSRect) {
        // nothing, ha!
        var myRect = dRect
      myRect.origin = CGPoint(x: dRect.origin.x, y: dRect.origin.y+4)
      
        myRect.size.height = myKnobImage!.size.height
      //myRect.offsetInPlace(dx:0, dy:4)
        myKnobImage!.drawInRect(myRect)
    }
    
}

