//
//  WindowController.swift
//  mpfree
//
//  Created by Harry Clegg on 03/12/2019.
//  Copyright © 2019 Harry Clegg. All rights reserved.
//

import Cocoa

enum ExportMode: Int {
    case append = 0
    case overwrite = 1
}

class WindowController: NSWindowController {
    
    var appDelegate: AppDelegate!
    var parser: ITParse!
    var exportOverwrite: ExportMode! = .append
    
    @IBAction func selectExportMode(_ sender: Any) {
        // Set a new export mode when the user clicks on the segmented control.
        guard let segmentedControl = sender as? NSSegmentedControl else { return }
        exportOverwrite = ExportMode.init(rawValue: segmentedControl.selectedSegment)
        print("WindowController.selectExportMode: \(exportOverwrite!) export mode selected")
    }
    
    @IBAction func selectFilterCriteria(_ sender: Any) {
        // Apply a set of filters to the playlists depending on which button was pressed.
        guard let segmentedControl = sender as? NSSegmentedControl else { return }
        let selectionState: SelectionState! = SelectionState.init(rawValue: segmentedControl.selectedSegment)
        print("WindowController.selectFilterCriteria: \(String(describing: selectionState)) filter criteria selected")
        
        // Update the selection status of the playlist model.
        parser.targetTree.setSelection(selectionState)
        
        // Redraw the view.
        parser.redrawTree()
    }
    
    @IBAction func selectExport(_ sender: NSToolbarItem) {
        // Perform the playlist export.
        
        print("WindowController.selectExport: export selected")
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        
        panel.message = "Select a location to export the playlists to."
        
        let response = panel.runModal()
        
        if response == NSApplication.ModalResponse.OK {
            guard let selectedURL = panel.url else { return }
            
            print("WindowController.selectExport: user has selected following path:")
            print(selectedURL.path)
            
            if exportOverwrite == .overwrite {
                // If overwrite mode, remove the folder first.
                
                print("WindowController.doExport: Clearing folder")
                if FileManager.default.fileExists(atPath: selectedURL.path) {
                    
                    do {
                        try FileManager.default.removeItem(atPath: selectedURL.path)
                    } catch {
                        print(error.localizedDescription);
                    }
                    
                    if FileManager.default.fileExists(atPath: selectedURL.path) {
                        print("WindowController.doExport: Failed to remove folder")
                    }
                }
            }
            

            if !FileManager.default.fileExists(atPath: selectedURL.path) {
                // If folder does not exist, make folder.

                print("WindowController.doExport: Creating new folder.")
                do {
                    try FileManager.default.createDirectory(atPath: selectedURL.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print(error.localizedDescription);
                }
                
            }
            
            // Call export function.
            parser.exportPlaylists(exportURL: selectedURL)
        } else {
            print("WindowController.selectExport: user cancelled")
        }
    }
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        appDelegate = (NSApplication.shared.delegate as! AppDelegate)
        parser = appDelegate.parser
        
    }
    
}
