//
//  DicomImageView.swift
//  DCMView
//
//  Created by Changmook Chun on 10/22/23.
//

import Cocoa
import os
import DcmtkInterfaceLib

let DCMViewImageViewDidSendMouseLocationNotification
= NSNotification.Name("com.teaeles.dcmview.DCMViewViewDidSendMouseLocationNotification")

let DCMViewImageViewMouseLocationKey
= "com.teaeles.dcmview.DCMViewImageViewMouseLocationKey"

struct ImagePoint {
    let u: Int
    let v: Int
}

class DicomImageView: NSImageView {
    var width: Int = 0
    var height: Int = 0
  
    var mouseLocationInImage: ImagePoint = ImagePoint(u: 0, v: 0)
    var currentHU: Int16 = 0
    
    var mouseRolloverEnabled = false
    
    // To support mouse moved events
    override func viewDidMoveToWindow() {
        window?.acceptsMouseMovedEvents = true
        
        let options: NSTrackingArea.Options = [
            NSTrackingArea.Options.mouseMoved,
            NSTrackingArea.Options.activeAlways,
            NSTrackingArea.Options.inVisibleRect]
        
        let trackingArea = NSTrackingArea(rect: NSRect(), options: options, owner: self)
        
        addTrackingArea(trackingArea)
    }
    
    override func mouseDown(with event: NSEvent) {
        // Convert mouse coordinate
//        let pointInView = convert(event.locationInWindow, from: nil)
//        let pointInImage = imagePoint(from: pointInView)
//        
//        let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "event")
//        logger.log("Mouse coordinates = \(pointInView.x), \(pointInView.y), Image coordinates = \(pointInImage.u), \(pointInImage.v)")
//        mouseLocationInImage = pointInImage
//        
//        let pixelDataRaw = get_pixel_data_raw()!
//        currentHU = rawDataValue(from: pixelDataRaw, at: mouseLocationInImage.u, and: mouseLocationInImage.v)
//        
//        let notificationCenter = NotificationCenter.default
//        notificationCenter.post(name: DCMViewImageViewDidSendMouseLocationNotification, object: self, userInfo: nil)
    }
    
    override func mouseMoved(with event: NSEvent) {
        if mouseRolloverEnabled {
            // Convert mouse coordinate
            let pointInView = convert(event.locationInWindow, from: nil)
            let pointInImage = imagePoint(from: pointInView)
            
            let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "event")
            logger.log("Mouse coordinates = \(pointInView.x), \(pointInView.y), Image coordinates = \(pointInImage.u), \(pointInImage.v)")
            
            mouseLocationInImage = pointInImage
            
            let pixelDataRaw = get_pixel_data_raw()!
            currentHU = rawDataValue(from: pixelDataRaw, at: mouseLocationInImage.u, and: mouseLocationInImage.v)
            
            let notificationCenter = NotificationCenter.default
            notificationCenter.post(name: DCMViewImageViewDidSendMouseLocationNotification, object: self, userInfo: nil)
        }
    }
  
    func rawDataValue(from data: UnsafeRawPointer, at u: Int, and v: Int) -> Int16 {
        let pointer = data.bindMemory(to: Int16.self, capacity: width * height)
        return pointer[v * width + u]
    }
    
    func imagePoint(from point: NSPoint) -> ImagePoint {
        let x = saturate(value: point.x, toUpper: width, andLowerLimit: 0)
        let y = saturate(value: CGFloat(height) - point.y, toUpper: height, andLowerLimit: 0)
        
        return ImagePoint(u: x, v: y)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
