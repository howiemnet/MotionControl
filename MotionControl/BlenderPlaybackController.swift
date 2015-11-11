//
//  BlenderPlaybackController.swift
//
//
//  Created by h on 16/10/2015.
//
//

import Cocoa

class BlenderPlaybackController: NSObject {
    
    var fileLoaded = false
    var framesLoaded = 0
    var firstFrame = 0
    var lastFrame = 0
    var channelsLoaded = 0
    var currentFrame = 0
    var channelIDs = [Int:Int]()
    var motionData = [Int:[Double]]()
    var csvData: CSwiftV? = nil
    var fileURL = NSURL()
    
    
    @IBOutlet weak var executiveController: ExecutiveController!
    @IBOutlet weak var theView: NSView!
    @IBOutlet weak var fileNameLabel: NSTextField!
    @IBOutlet weak var playbackPositionSlider: NSSlider!
    @IBOutlet weak var firstFrameField: NSTextField!
    @IBOutlet weak var lastFrameField: NSTextField!
    @IBOutlet weak var currentFrameField: NSTextField!
    
    @IBOutlet weak var refreshButton: NSButton!
    
    @IBOutlet weak var graphView: BlenderPreviewGraph!
    
    
    @IBAction func buttonPressed(sender: NSButton) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = "Open a Blender playback file"
        panel.beginSheetModalForWindow(theView.window!) { (result: Int) -> Void in
            Swift.print ("Result: \(result), File selected: \(panel.URL)")
            if (result == 1) && (panel.URL != nil) {
                self.fileURL = panel.URL!
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setURL(self.fileURL, forKey:"lastBlenderFile")
                
                self.refreshBlenderFile()
            }
        }
        
    }
    
    @IBAction func playbackPositionSlider(sender: NSSlider) {
        currentFrame = sender.integerValue
        currentFrameField.integerValue = currentFrame
        executiveController.setCurrentChannelPositions(getChannelPosDictForFrame(currentFrame))
        
    }
    
    func getChannelPosDictForFrame(frame: Int) -> [Int:Double] {
        var channelSet: [Int:Double] = [:]
        for (channel,data) in motionData {
            channelSet[channel] = data[frame]
        }
        return channelSet
    }
    
    @IBAction func refreshFile(sender: NSButton) {
        refreshBlenderFile()
    }
    
    func refreshBlenderFile() {
        fileNameLabel.stringValue = fileURL.path!
        var theFileData = ""
        do {
            theFileData = try String(contentsOfURL: fileURL)
            fileLoaded = true
            refreshButton.enabled = true
        } catch {
            print ("Error loading file")
            fileLoaded = false
            refreshButton.enabled = false
            
        }
        
        if fileLoaded {
            csvData = CSwiftV(String: theFileData)
            framesLoaded = csvData!.rows.count
            print ("Loaded channels: \(csvData!.headers)")
            print ("Loaded \(framesLoaded) frames")
            
            // --------------------------------------
            //
            //  Get playback range
            //
            // --------------------------------------
            
            firstFrame = Int(csvData!.rows[0][0])!
            lastFrame = (firstFrame + framesLoaded) - 1
            
            firstFrameField.integerValue = firstFrame
            lastFrameField.integerValue = lastFrame
            currentFrameField.integerValue = firstFrame
            
            playbackPositionSlider.minValue = Double(firstFrame)
            playbackPositionSlider.maxValue = Double(lastFrame)
            playbackPositionSlider.integerValue = firstFrame
            playbackPositionSlider.enabled = true
            
            
            // --------------------------------------
            //
            //  Match up the channels...
            //
            // --------------------------------------
            
            motionData = [:]
            channelIDs = [:]
            
            for (columnNumber, headerName) in csvData!.headers.enumerate() {
                if headerName != "FRAME" {
                    let chanID = executiveController.getIDForName(headerName)
                    if chanID != nil {
                        channelIDs[columnNumber] = chanID
                        motionData[chanID!] = [Double]()
                    }
                }
            }
            
            print ("\(channelIDs.count) channel(s) matched up")
            
            // --------------------------------------
            //
            //  Process the motion data...
            //
            // --------------------------------------
            
            
            var graphingData = Array(count: csvData!.headers.count, repeatedValue: ChannelGraphData())
            
            
            for (csvRow) in csvData!.rows {
                //var thePositions = [Int:Double]()
                for (columnNumber, data) in csvRow.enumerate() {
                    if (channelIDs[columnNumber] != nil) {
                        motionData[channelIDs[columnNumber]!]!.append(Double(data)!)
                    }
                    graphingData[columnNumber].data.append(Double(data)!);
                    
                }
                //motionData.append(thePositions)
            }
            
            print ("data loaded")
            playButton.enabled = true
            rewindButton.enabled = true
            graphView.graphData = graphingData
            
            
            
        }
        
        
    }
    
    
    @IBOutlet weak var rewindButton: NSButton!
    @IBOutlet weak var stopButton: NSButton!
    @IBOutlet weak var playButton: NSButton!
    
    
    
    @IBAction func rewindButton(sender: NSButton) {
        currentFrame = firstFrame
        currentFrameField.integerValue = firstFrame
        playbackPositionSlider.integerValue = firstFrame
        executiveController.setCurrentChannelPositions(getChannelPosDictForFrame(firstFrame))
    }
    
    
    @IBAction func stopButton(sender: NSButton) {
        executiveController.requestStopPlayback()
    }
    
    
    @IBAction func playButton(sender: NSButton) {
        executiveController.requestStartPlayback()
    }
    
    func getDataStreamsForAllChannels() -> [Int:[Double]] {
        return motionData
    }
    
    func getDataStreamForChannel(channelID: Int) -> [Double] {
        return motionData[channelID]!
    }
    
    func getPositionsForFirstFrame() -> [Int:Double] {
        return getChannelPosDictForFrame(firstFrame)
    }
    
    
    override init() {
        super.init()
        let defaults = NSUserDefaults.standardUserDefaults()
        if let previousURL = defaults.URLForKey("lastBlenderFile") {
            fileURL = previousURL
        }
        
    }
    
    
    func updateCurrentPlaybackFrame(theFrame: Int) {
        playbackPositionSlider.integerValue = theFrame
        currentFrameField.integerValue = theFrame
    }
    
    
}
