//
//  AppDelegate.swift
//  DCMView
//
//  Created by Changmook Chun on 9/22/23.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet var window: NSWindow!
    @IBOutlet var infoTextField: NSTextField!
    @IBOutlet var imageView: NSImageView!
   
    var width: Int = -1
    var height: Int = -1
    var depth: Int = -1
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        openDicomFile(self)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
   
    // func mask(from data: [UInt8], withWidth width: Int, andHeight height: Int) -> CGImage? {
    func mask(from data: UnsafePointer<UInt8>?, withWidth width: Int, andHeight height: Int) -> CGImage? {
//        guard data.count >= 8 else {
//            print("data too small")
//            return nil
//        }

//        let width  = Int(data[1]) | Int(data[0]) << 8
//        let height = Int(data[3]) | Int(data[2]) << 8

        let colorSpace = CGColorSpaceCreateDeviceGray()

//        guard
//            data.count >= width * height + 8,
        let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width, space: colorSpace, bitmapInfo: CGImageAlphaInfo.none.rawValue)!
        let buffer = context.data?.bindMemory(to: UInt8.self, capacity: width * height)
//        else {
//            return nil
//        }

        for index in 0 ..< width * height {
            buffer![index] = data![index]
        }

        return context.makeImage() //.flatMap { CGImage($0) }
    }
    
    @IBAction func openDicomFile(_ sender: AnyObject) {
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
                let state = create_reader(path)
                if (state == NO_ERR) {
                    let width = Int(get_width())
                    let height = Int(get_height())
                    let frameCount = get_frame_count()
                    
                    let depth = get_depth()
                    
                    let pixelData = get_pixel_data()
                   
                    infoTextField.stringValue = "Width = \(width), Height = \(height), Frame count = \(frameCount), Depth = \(depth)"
                    
                    // var srgbArray = [UInt32](repeating: 0xFF204080, count: 8*8)
                    // var data = [UInt8](repeating: 0xff, count: width*height)
                       
                    if let image = mask(from: pixelData, withWidth: width, andHeight: height) {
                        DispatchQueue.main.async {
                            let nsImg = NSImage(cgImage: image, size: .zero)
                            self.imageView.image = nsImg
                        }
                    }
                    
//                    let cgImg = grayscaleArray.withUnsafeMutableBytes { (ptr) -> CGImage in
//                        let ctx = CGContext(
//                            data: ptr.baseAddress,
//                            width: width,
//                            height: height,
//                            bitsPerComponent: 8,
//                            bytesPerRow: width,
//                            space: CGColorSpace(name: CGColorSpace.linearGray)!,
//                            bitmapInfo: CGBitmapInfo.byteOrder16Little.rawValue +
//                                CGImageAlphaInfo.premultipliedFirst.rawValue
//                            )!
//                        return ctx.makeImage()!
//                    }
//
//                    let nsImg = NSImage(cgImage: cgImg, size: .zero)
//                    imageView.image = nsImg
                    
                    window.setIsVisible(true)
                }
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
}

