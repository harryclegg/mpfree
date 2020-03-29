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

}


final class GeneralPreferenceViewController: NSViewController, PreferencePane {
    let preferencePaneIdentifier = PreferencePane.Identifier.general
    let preferencePaneTitle = "General"
    
    override var nibName: NSNib.Name? {
        return "GeneralPreferenceViewController"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override var preferredContentSize: CGSize {
        get { return CGSize(width: 560, height: 400) }
        set { super.preferredContentSize = newValue }
    }
    
    @IBAction func updateProblemPreferences(_: Any) {
        
        Defaults[.observableDummyKey] = !Defaults[.observableDummyKey]
 }
}
