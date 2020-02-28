//
//  WindowController.swift
//  mpfree
//
//  Created by Harry Clegg on 03/12/2019.
//  Copyright © 2019 Harry Clegg. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
        
    var appDelegate: AppDelegate!
    var parser: ITParse!
    
    @IBAction func doExport(_ sender: NSToolbarItem) {
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        
        panel.message = "Select a location to export the playlists to."
        
        let response = panel.runModal()
        
        if response == NSApplication.ModalResponse.OK {
            guard let selectedURL = panel.url else { return }
            parser.exportPlaylists(exportURL: selectedURL)
        }
    }
        
    
    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        
        
        appDelegate = (NSApplication.shared.delegate as! AppDelegate)
        parser = appDelegate.parser
        
    }

}
