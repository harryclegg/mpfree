//
//  AppDelegate.swift
//  mpfree
//
//  Created by Harry Clegg on 22/11/2019.
//  Copyright © 2019 Harry Clegg. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Class Properties
    let parser = ITParse()
    let rootFolderID: UInt64 = 10458245229335179718

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    // Close the whole app when the last (only) window closes.
    func applicationShouldTerminateAfterLastWindowClosed(_ app: NSApplication) -> Bool {
        return true
    }

}

