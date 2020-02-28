//
//  ExportFiltersViewController.swift
//  mpfree
//
//  Created by Harry Clegg on 11/01/2020.
//  Copyright © 2020 Harry Clegg. All rights reserved.
//

import Cocoa

class ExportFiltersViewController: NSViewController {
    
    @IBOutlet weak var startsWithTextField: NSTextField!
    @IBOutlet weak var endsWithTextField: NSTextField!
    @IBOutlet weak var applyNowCheckButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cancelFilterChange(_ sender: Any) {
        guard let window = self.view.window, let parent = window.sheetParent else { return }
        parent.endSheet(window, returnCode: .cancel)
    }
  
    @IBAction func saveNewFilters(_ sender: Any) {
        guard let window = self.view.window, let parent = window.sheetParent else { return }
        parent.endSheet(window, returnCode: .OK)
    }
    
}
