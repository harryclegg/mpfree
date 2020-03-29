//
//  ExportingPreferenceViewController.swift
//  mpfree
//
//  Created by Harry Clegg on 28/02/2020.
//  Copyright © 2020 Harry Clegg. All rights reserved.
//

import Cocoa
import Defaults
import Preferences

extension Defaults.Keys {
    static let exportPathFlatMode = Key<Bool>("exportPathFlatMode", default: false)
    static let exportPathFlatDelimiter = Key<String>("exportPathFlatDelimiter", default: ".")
    
    static let exportFilterPrefixString = Key<String>("exportFilterPrefixString", default: "")
    static let exportFilterSuffixString = Key<String>("exportFilterSuffixString", default: "")
    static let exportStripPathPrefix = Key<Bool>("exportStripPathPrefix", default: false)
    static let exportStripPathSuffix = Key<Bool>("exportStripPathSuffix", default: false)
}

final class ExportingPreferenceViewController: NSViewController, PreferencePane {
    let preferencePaneIdentifier = PreferencePane.Identifier.exporting
    let preferencePaneTitle = "Export"
    
    override var nibName: NSNib.Name? {
        return "ExportingPreferenceViewController"
    }
    
    // Flat path export mode
    
    @IBOutlet weak var shouldExportFlat: NSButton!
    @IBOutlet weak var exportFlatDelimiter: NSTextField!
    
    // Prefix/Suffix filtering
    @IBOutlet weak var shouldStripPathPrefixCheckbox: NSButton!
    @IBOutlet weak var shouldStripPathSuffixCheckbox: NSButton!
    
    @IBOutlet weak var exportFilterPrefixStringTextField: NSTextField!
    @IBOutlet weak var exportFilterSuffixStringTextField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Defaults[.exportPathFlatMode] {
            shouldExportFlat.state = .on
        } else {
            shouldExportFlat.state = .off
        }
        exportFlatDelimiter.stringValue = Defaults[.exportPathFlatDelimiter]
        
        if Defaults[.exportStripPathPrefix] {
            shouldStripPathPrefixCheckbox.state = .on
        } else {
            shouldStripPathPrefixCheckbox.state = .off
        }
        
        if Defaults[.exportStripPathSuffix] {
            shouldStripPathSuffixCheckbox.state = .on
        } else {
            shouldStripPathSuffixCheckbox.state = .off
        }
        
        exportFilterPrefixStringTextField.stringValue = Defaults[.exportFilterPrefixString]
        exportFilterSuffixStringTextField.stringValue = Defaults[.exportFilterSuffixString]
    }
    
    @IBAction func updatePreferences(_: Any) {
        if shouldStripPathPrefixCheckbox.state == .on {
            Defaults[.exportStripPathPrefix] = true
        } else {
            Defaults[.exportStripPathPrefix] = false
        }
        
        if shouldStripPathSuffixCheckbox.state == .on {
            Defaults[.exportStripPathSuffix] = true
        } else {
            Defaults[.exportStripPathSuffix] = false
        }
        
        Defaults[.exportFilterPrefixString] = exportFilterPrefixStringTextField.stringValue
        
        Defaults[.exportFilterSuffixString] = exportFilterSuffixStringTextField.stringValue
        
        Defaults[.observableDummyKey] = !Defaults[.observableDummyKey]
    }
    
    @IBAction func enableDisableFlatExport(_ sender: Any) {
        Defaults[.exportPathFlatMode] = (shouldExportFlat.state == .on)
    }
    @IBAction func setFlatExportDelimiter(_ sender: Any) {
        Defaults[.exportPathFlatDelimiter] = exportFlatDelimiter.stringValue
    }
}
