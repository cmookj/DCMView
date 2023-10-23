//
//  AppDelegate.swift
//  DCMView
//
//  Created by Changmook Chun on 9/22/23.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var windowControllers: [MainWindowController] = []
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        addWindowController()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func addWindowController() {
        let windowController = MainWindowController()
        windowController.showWindow(self)
        if windowController.shouldShowWindow {
            windowControllers.append(windowController)
        }
        else {
            windowController.close()
        }
    }
    
    @IBAction func displayNewWindow(_ sender: NSMenuItem) {
        addWindowController()
    }
}

