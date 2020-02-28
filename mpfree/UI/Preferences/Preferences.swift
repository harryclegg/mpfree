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
}

extension PreferencePane.Identifier {
    static let general = Identifier("general")
    static let exporting = Identifier("exporting")
}

