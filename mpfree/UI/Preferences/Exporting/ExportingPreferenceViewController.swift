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
    @IBOutlet weak var exportFlatDelimiterLabel: NSTextField!
    
    public override var preferredContentSize: CGSize {
        get { return CGSize(width: 445, height: 315) }
        set { super.preferredContentSize = newValue }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Defaults[.exportPathFlatMode] {
            shouldExportFlat.state = .on
            exportFlatDelimiterLabel.textColor = .labelColor
            exportFlatDelimiter.isEnabled = true
        } else {
            shouldExportFlat.state = .off
            exportFlatDelimiterLabel.textColor = .secondaryLabelColor
            exportFlatDelimiter.isEnabled = false
        }
        
        exportFlatDelimiter.stringValue = Defaults[.exportPathFlatDelimiter]
    }
    
    @IBAction func enableDisableFlatExport(_ sender: Any) {
        Defaults[.exportPathFlatMode] = (shouldExportFlat.state == .on)
        if Defaults[.exportPathFlatMode] {
            exportFlatDelimiterLabel.textColor = .labelColor
            exportFlatDelimiter.isEnabled = true
        } else {
            exportFlatDelimiterLabel.textColor = .secondaryLabelColor
            exportFlatDelimiter.isEnabled = false
        }
    }
    
    @IBAction func setFlatExportDelimiter(_ sender: Any) {
        Defaults[.exportPathFlatDelimiter] = exportFlatDelimiter.stringValue
    }
}
