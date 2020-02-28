//
//  WindowController.swift
//  mpfree
//
//  Created by Harry Clegg on 03/12/2019.
//  Copyright © 2019 Harry Clegg. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    
    @IBOutlet weak var rootPlaylistToolbar: NSToolbarItem!
        
    var appDelegate: AppDelegate!
    var parser: ITParse!
    
    
    @IBAction func showFilterView(_ sender: NSToolbarItem) {

        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let exportFiltersWindowController = storyboard.instantiateController(withIdentifier: "ExportFiltersWindowController") as! NSWindowController
        
        // Create the window.
        guard let exportFiltersWindow = exportFiltersWindowController.window,
            let resizeViewController = exportFiltersWindowController.contentViewController as? ExportFiltersViewController
        else {return}

        // Read default filter values. Apply them to the UI text boxes.
        let defaults = UserDefaults.standard
        if let startsWithFromUserDefaults = defaults.string(forKey: "filterStartsWith") {
            resizeViewController.startsWithTextField.stringValue = startsWithFromUserDefaults
        }
        if let endsWithFromUserDefaults = defaults.string(forKey: "filterEndsWith") {
            resizeViewController.endsWithTextField.stringValue = endsWithFromUserDefaults
        }
        
        self.window!.beginSheet(exportFiltersWindow, completionHandler: { (response) in
            // If user presses OK, do the following. Pressing cancel does nothing.
            if response == NSApplication.ModalResponse.OK {
                
                // Save new filter values to defaults file.
                defaults.set(resizeViewController.startsWithTextField.stringValue, forKey: "filterStartsWith")
                defaults.set(resizeViewController.endsWithTextField.stringValue, forKey: "filterEndsWith")
                
                if resizeViewController.applyNowCheckButton.state == NSControl.StateValue.on {
                    // Reset all playlist selections to match filters
                    
                }
            }
           })
    }
    
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
