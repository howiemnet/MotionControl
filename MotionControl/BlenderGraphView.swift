//
//  BlenderGraphView.swift
//  MotionControl
//
//  Created by h on 27/10/2015.
//  Copyright © 2015 slartibartfist. All rights reserved.
//

import Cocoa


struct ChannelGraphData {
    var data = [Double]()
}


class BlenderPreviewGraph : NSView {
    
   // @IBOutlet weak var graphView: BlenderPreviewGraph!
    
    override var opaque: Bool {
        get {
            return true
        }
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //dataBounds = NSRect(x: 0, y: -600, width: 500, height: 1200)
    }

    
    var graphData = [ChannelGraphData]() {
        didSet {
            if (graphData.count > 0) {
                updateGraph()
        
            }
        }
    }
    
    
    var xScale = CGFloat(0)
    var yScales = [CGFloat]()
    var yOffsets = [CGFloat]()
    
    
    
    
    
    
    func updateGraph() {
        xScale = self.bounds.width / CGFloat(graphData[0].data.count - 1)
        yScales = []
        yOffsets = []
        let viewHeight = self.bounds.height
        
        // calc scales
        
        for channelData in graphData {
            var minY = 9999999.0
            var maxY = 0.0
            for value in channelData.data {
                if value < minY { minY = value }
                if value > maxY { maxY = value }
            }
            yOffsets.append( CGFloat(minY) )
            if (maxY - minY) == 0.0 {
                yScales.append(1.0)
                
            } else {
            yScales.append( viewHeight / CGFloat(maxY - minY))
        }
        }
        
        
        self.setNeedsDisplayInRect(self.bounds)
    }
    
    
    override func drawRect(dirtyRect: NSRect) {
        
        let backgroundPath = NSBezierPath(rect: dirtyRect)
        NSColor.whiteColor().setFill()
        backgroundPath.fill()
        let dashPattern = [5.0,5.0]
        
        // ---------------------------------
        //
        //  Grid lines
        //
        // ---------------------------------
        
        /*let firstXGridline = (Int(dataLeft / gridLinesXSpacing) + 1)
        let lastXGridline = (Int(dataRight / gridLinesXSpacing))
        NSColor(calibratedWhite: 0.9, alpha: 1.0).setStroke()
        for i in firstXGridline...lastXGridline {
            let myPath = NSBezierPath()
            myPath.moveToPoint(graphScale.scalePointToView(NSPoint(x: CGFloat(gridLinesXSpacing * i), y: CGFloat(dataBounds.minY))))
            myPath.lineToPoint(graphScale.scalePointToView(NSPoint(x: CGFloat(gridLinesXSpacing * i), y: CGFloat(dataBounds.maxY))))
            myPath.stroke()
        }
        
        
        let firstYGridline = (Int(Int(dataBounds.minY) / gridLinesYSpacing))
        let lastYGridline = (Int(Int(dataBounds.maxY) / gridLinesYSpacing))
        NSColor(calibratedWhite: 0.9, alpha: 1.0).setStroke()
        
        
        for i in firstYGridline...lastYGridline {
            let myPath = NSBezierPath()
            myPath.moveToPoint(graphScale.scalePointToView(NSPoint(x: CGFloat(dataBounds.minX), y: CGFloat(gridLinesYSpacing * i))))
            myPath.lineToPoint(graphScale.scalePointToView(NSPoint(x: CGFloat(dataBounds.maxX), y: CGFloat(gridLinesYSpacing * i))))
            myPath.setLineDash(UnsafePointer(dashPattern), count: 2, phase: CGFloat(0.0))
            myPath.stroke()
        }

        
        // ---------------------------------
        //
        //  Origin (y=0) line
        //
        // ---------------------------------
        
        
        if (dataBounds.minY < 0.0) && (dataBounds.maxY > 0.0) {
            let myGridLineYZero = NSBezierPath()
            myGridLineYZero.moveToPoint(graphScale.scalePointToView(NSPoint(x: 0.0, y: 0.0)))
            myGridLineYZero.lineToPoint(graphScale.scalePointToView(NSPoint(x: 1000.0, y: 0.0)))
            NSColor(calibratedWhite: 0.4, alpha: 1.0).setStroke()
            // NSColor.blueColor().setStroke()
            myGridLineYZero.lineWidth = CGFloat(2)
            myGridLineYZero.stroke()
        }
      */
        
        var myColours = [NSColor.blueColor(),NSColor.redColor(),NSColor.greenColor()]
        
        if xScale != 0 {
            var channelNum = 0
            for (index, channelData) in graphData.enumerate() {
                let myPath = NSBezierPath()
                myPath.moveToPoint(NSPoint(x: 0, y: (yScales[index] * (CGFloat(channelData.data[0]) - yOffsets[index]) )))
                for x in 1...channelData.data.count-1 {
                    myPath.lineToPoint(NSPoint(x: CGFloat(x)*xScale, y: (yScales[index] * ( CGFloat(channelData.data[x]) - yOffsets[index]) )))
                }
                
                myColours[channelNum % 3].setStroke()
                myPath.stroke()
                channelNum++
            }
        }
    }
    
}