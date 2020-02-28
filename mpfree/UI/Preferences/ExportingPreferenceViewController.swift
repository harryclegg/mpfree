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
    static let exportFilterPrefixString = Key<String>("exportFilterPrefixString", default: "")
    static let exportFilterPostfixString = Key<String>("exportFilterPostfixString", default: "")
    static let exportStripPathPrefix = Key<Bool>("exportStripPathPrefix", default: false)
    static let exportStripPathPostfix = Key<Bool>("exportStripPathPostfix", default: false)
    
}

final class ExportingPreferenceViewController: NSViewController, PreferencePane {
    let preferencePaneIdentifier = PreferencePane.Identifier.exporting
    let preferencePaneTitle = "Export"
    
    override var nibName: NSNib.Name? {
        return "ExportingPreferenceViewController"
    }
        
    @IBOutlet weak var shouldStripPathPrefixCheckbox: NSButton!
    @IBOutlet weak var shouldStripPathPostfixCheckbox: NSButton!
    
    @IBOutlet weak var exportFilterPrefixStringTextField: NSTextField!
    @IBOutlet weak var exportFilterPostfixStringTextField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Defaults[.exportStripPathPrefix] {
            shouldStripPathPrefixCheckbox.state = .on
        } else {
            shouldStripPathPrefixCheckbox.state = .off
        }
        
        if Defaults[.exportStripPathPostfix] {
            shouldStripPathPostfixCheckbox.state = .on
        } else {
            shouldStripPathPostfixCheckbox.state = .off
        }
        
        exportFilterPrefixStringTextField.stringValue = Defaults[.exportFilterPrefixString]
        
        exportFilterPostfixStringTextField.stringValue = Defaults[.exportFilterPostfixString]
    }
    
    @IBAction func updatePreferences(_: Any) {
        if shouldStripPathPrefixCheckbox.state == .on {
            Defaults[.exportStripPathPrefix] = true
        } else {
            Defaults[.exportStripPathPrefix] = false
        }
        
        if shouldStripPathPostfixCheckbox.state == .on {
            Defaults[.exportStripPathPostfix] = true
        } else {
            Defaults[.exportStripPathPostfix] = false
        }
        
        Defaults[.exportFilterPrefixString] = exportFilterPrefixStringTextField.stringValue
        
        Defaults[.exportFilterPostfixString] = exportFilterPostfixStringTextField.stringValue
        
        Defaults[.observableDummyKey] = !Defaults[.observableDummyKey]
    }
    
}
