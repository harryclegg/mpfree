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
}

final class ExportingPreferenceViewController: NSViewController, PreferencePane {
    let preferencePaneIdentifier = PreferencePane.Identifier.exporting
    let preferencePaneTitle = "Export"

    override var nibName: NSNib.Name? {
        return "ExportingPreferenceViewController"
    }
}
