//
//  MainWindowController.swift
//  DCMView
//
//  Created by Changmook Chun on 10/20/23.
//

import Cocoa


class MainWindowController: NSWindowController {

    @IBOutlet weak var imageView: DicomImageView!
    @IBOutlet weak var infoStringField: NSTextField!
   
    var width: Int = 0
    var height: Int = 0
    var frameCount: Int = 0
    var depth: Int = 0
    
    var level = 0
    
    var shouldShowWindow = false
    
    @objc var greyLevel = 2000 {
        willSet {
            willChangeValue(forKey: "minLevel")
            willChangeValue(forKey: "maxLevel")
        }
        
        didSet {
            didChangeValue(forKey: "minLevel")
            didChangeValue(forKey: "maxLevel")
            
            level = -greyLevel + 2000
            displayImage()
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
            
            displayImage()
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

    deinit {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self)
    }
    
    func loadDicom(with path: String) {
        let state = create_reader(path)
        if (state == NO_ERR) {
            width = Int(get_width())
            height = Int(get_height())
            frameCount = Int(get_frame_count())
            depth = Int(get_depth())
            
            let imageRect: NSRect = NSMakeRect(0.0, 0.0, CGFloat(width), CGFloat(height))
            imageView.bounds = imageRect
            
            displayImage()
            
            imageView.mouseRolloverEnabled = true
        }
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
    
    func displayImage() {
        let width = Int(get_width())
        let height = Int(get_height())
        
        let pixelDataRaw = get_pixel_data_raw()!
        let signed = signed_representation() == 1 ? true : false
        let byteSize = Int(byte_size_representation())
        
        if let image = mask(from: pixelDataRaw, withWidth: width, andHeight: height, withByteSize: byteSize, andSigned: signed) {
            self.imageView.width = width
            self.imageView.height = height
            
            DispatchQueue.main.async {
                let nsImg = NSImage(cgImage: image, size: .zero)
                self.imageView.image = nsImg
            }
        }
    }
   
    @objc func receiveViewDidSendMouseLocationNotification(_ note: NSNotification) {
        infoStringField.stringValue = "(\(imageView.mouseLocationInImage.u), \(imageView.mouseLocationInImage.v)) \(imageView.currentHU)"
        
    }
    
    override var windowNibName: String {
        return "MainWindowController"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(receiveViewDidSendMouseLocationNotification),
                                               name: DCMViewImageViewDidSendMouseLocationNotification,
                                               object: nil)
        
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Choose a DICOM file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedContentTypes     = [.data];

        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let path = result!.path
                loadDicom(with: path)
                shouldShowWindow = true
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }

}
