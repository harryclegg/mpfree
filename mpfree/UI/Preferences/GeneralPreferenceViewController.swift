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
    static let isCacheInvalidationHard = Key<Bool>("isCacheInvalidationHard", default: true)
    static let isNamingThingsHard = Key<Bool>("isNamingThingsHard", default: true)
}


final class GeneralPreferenceViewController: NSViewController, PreferencePane {
    let preferencePaneIdentifier = PreferencePane.Identifier.general
    let preferencePaneTitle = "General"
    
    override var nibName: NSNib.Name? {
        return "GeneralPreferenceViewController"
    }
    
    @IBOutlet var isCacheInvalidationHardCheckbox: NSButton!
    @IBOutlet var isNamingThingsHardCheckbox: NSButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        if Defaults[.isCacheInvalidationHard] {
            isCacheInvalidationHardCheckbox.state = .on
        } else {
            isCacheInvalidationHardCheckbox.state = .off
        }
        
        if Defaults[.isNamingThingsHard] {
            isNamingThingsHardCheckbox.state = .on
        } else {
            isNamingThingsHardCheckbox.state = .off
        }
        
    }

    @IBAction func updateProblemPreferences(_: Any) {
        if isCacheInvalidationHardCheckbox.state == .on {
            Defaults[.isCacheInvalidationHard] = true
        } else {
            Defaults[.isCacheInvalidationHard] = false
        }
        
        if isNamingThingsHardCheckbox.state == .on {
            Defaults[.isNamingThingsHard] = true
        } else {
            Defaults[.isNamingThingsHard] = false
        }
        
        Defaults[.observableDummyKey] = !Defaults[.observableDummyKey]
 }
}
