//
//  CheckboxCell.swift
//  mpfree
//
//  Created by Harry Clegg on 11/01/2020.
//  Copyright © 2020 Harry Clegg. All rights reserved.
//

import Foundation
import Cocoa

/// A set of methods that `CheckboxCelView` use to communicate changes to another object
protocol CheckboxCellViewDelegate {
    func checkboxCellView(_ cell: CheckboxCellView, didChangeState state: NSControl.StateValue)
}

class CheckboxCellView: NSTableCellView {

    /// The checkbox button
    @IBOutlet weak var checkboxButton: NSButton!

    /// The item that represent the row in the outline view
    /// We may potentially use this cell for multiple outline views so let's make it generic
    var item: Any?

    /// The delegate of the cell
    var delegate: CheckboxCellViewDelegate?

    override func awakeFromNib() {
        checkboxButton.target = self
        checkboxButton.action = #selector(self.didChangeState(_:))
    }

    /// Notify the delegate that the checkbox's state has changed
    @objc private func didChangeState(_ sender: NSObject) {
        delegate?.checkboxCellView(self, didChangeState: checkboxButton.state)
    }
}
