//
//  MainWindowController.swift
//  DCMView
//
//  Created by Changmook Chun on 10/20/23.
//

import Cocoa

class MainWindowController: NSWindowController {

    override var windowNibName: String {
        return "MainWindowController"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.width = Int(get_width())
        self.height = Int(get_height())
        self.frameCount = Int(get_frame_count())
        self.depth = Int(get_depth())
        
        // let pixelDataUnsigned = get_pixel_data_unsigned()
       
        // infoTextField.stringValue = "Width = \(width), Height = \(height), Frame count = \(frameCount), Depth = \(depth)"
        redisplayImage()
        
        // window.setIsVisible(true)
    }
    
    @IBOutlet weak var infoTextField: NSTextField!
    @IBOutlet weak var imageView: DicomImageView! // NSImageView!
   
    var width: Int = -1
    var height: Int = -1
    var depth: Int = -1
    var frameCount: Int = -1
    var level = 0
    
    @objc var greyLevel = 2000 {
        willSet {
            willChangeValue(forKey: "minLevel")
            willChangeValue(forKey: "maxLevel")
        }
        
        didSet {
            didChangeValue(forKey: "minLevel")
            didChangeValue(forKey: "maxLevel")
            
            level = -greyLevel + 2000
            redisplayImage()
        }
    }
    
    @objc var greyWindow = 2000 {
        willSet {
            willChangeValue(forKey: "minLevel")
            willChangeValue(forKey: "maxLevel")
        }
        
        didSet {
            didChangeValue(forKey: "minLevel")
            didChangeValue(forKey: "maxLevel")
            
            redisplayImage()
        }
    }
    
    @objc var minLevel: Int {
        get {
            return greyLevel - greyWindow/2
        }
    }
    
    @objc var maxLevel: Int {
        get {
            return greyLevel + greyWindow/2
        }
    }
    
    func applyWindowAndLevel(to val: Int16) -> UInt8 {
        let white = level + greyWindow/2
        let black = level - greyWindow/2
        
        if val >= white {
            return UInt8(255)
        }
        else if val <= black {
            return UInt8(0)
        }
        return UInt8((Double(val) - Double(black))/Double(greyWindow) * 255)
    }
    
    func mask(from data: UnsafeRawPointer, withWidth width: Int, andHeight height: Int, withByteSize size: Int, andSigned signed: Bool) -> CGImage? {
        let colorSpace = CGColorSpaceCreateDeviceGray()

        let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width, space: colorSpace, bitmapInfo: CGImageAlphaInfo.none.rawValue)!
        let buffer = context.data?.bindMemory(to: UInt8.self, capacity: width * height)
        
        if (signed == true) {
            if (size == 1) {
                let pointer = data.bindMemory(to: Int8.self, capacity: width * height)
                
                for index in 0 ..< width * height {
                    buffer![index] = UInt8(Double(pointer[index])/4000 * 256)
                }
            }
            else if (size == 2) {
                let pointer = data.bindMemory(to: Int16.self, capacity: width * height)
                
                for index in 0 ..< width * height {
                    // buffer![index] = UInt8(Double(pointer[index] + 1000)/4000 * 256)
                    buffer![index] = applyWindowAndLevel(to: pointer[index])
                }
            }
            else if (size == 4) {
                let pointer = data.bindMemory(to: Int32.self, capacity: width * height)
                
                for index in 0 ..< width * height {
                    buffer![index] = UInt8(Double(pointer[index])/4000 * 256)
                }
            }
        }
        else {
            if (size == 1) {
                let pointer = data.bindMemory(to: UInt8.self, capacity: width * height)
                
                for index in 0 ..< width * height {
                    buffer![index] = UInt8(Double(pointer[index])/4000 * 256)
                }
            }
            else if (size == 2) {
                let pointer = data.bindMemory(to: UInt16.self, capacity: width * height)
                
                for index in 0 ..< width * height {
                    buffer![index] = UInt8(Double(pointer[index] + 1000)/4000 * 256)
                }
            }
            else if (size == 4) {
                let pointer = data.bindMemory(to: UInt32.self, capacity: width * height)
                
                for index in 0 ..< width * height {
                    buffer![index] = UInt8(Double(pointer[index])/4000 * 256)
                }
            }
        }

        return context.makeImage()
    }
   
    func redisplayImage() {
        let width = Int(get_width())
        let height = Int(get_height())
        
        let pixelDataRaw = get_pixel_data_raw()!
        let signed = signed_representation() == 1 ? true : false
        let byteSize = Int(byte_size_representation())
        
        if let image = mask(from: pixelDataRaw, withWidth: width, andHeight: height, withByteSize: byteSize, andSigned: signed) {
            DispatchQueue.main.async {
                let nsImg = NSImage(cgImage: image, size: .zero)
                self.imageView.image = nsImg
            }
        }
    }

}
