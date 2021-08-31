//
//  Preferences.swift
//  mpfree
//
//  Created by Harry Clegg on 28/02/2020.
//  Copyright © 2020 Harry Clegg. All rights reserved.
//

import Cocoa
import Defaults
import Preferences

extension Defaults.Keys {
    static let observableDummyKey = Key<Bool>("dummyChanged", default: false)
    static let debugPrintTags = Key<Bool>("debugPrintTags", default: false)
}

extension Preferences.PaneIdentifier {
    static let general = Self("general")
    static let exporting = Self("exporting")
}
