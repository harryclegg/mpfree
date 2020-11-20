//
//  GeneralPreferenceViewController.swift
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
    static let exportFilterSuffixString = Key<String>("exportFilterSuffixString", default: "")
    static let exportStripPathPrefix = Key<Bool>("exportStripPathPrefix", default: false)
    static let exportStripPathSuffix = Key<Bool>("exportStripPathSuffix", default: false)
}


final class GeneralPreferenceViewController: NSViewController, PreferencePane {
    let preferencePaneIdentifier = Preferences.PaneIdentifier.general
    let preferencePaneTitle = "General"
    
    // Prefix/Suffix filtering
    @IBOutlet weak var exportFilterPrefixStringTextField: NSTextField!
    @IBOutlet weak var shouldStripPathPrefixCheckbox: NSButton!
    
    @IBOutlet weak var exportFilterSuffixStringTextField: NSTextField!
    @IBOutlet weak var shouldStripPathSuffixCheckbox: NSButton!

    override var nibName: NSNib.Name? {
        return "GeneralPreferenceViewController"
    }
    
    public override var preferredContentSize: CGSize {
        get { return CGSize(width: 445, height: 315) }
        set { super.preferredContentSize = newValue }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    @IBAction func updateProblemPreferences(_: Any) {
        
        Defaults[.observableDummyKey] = !Defaults[.observableDummyKey]
    }
}
