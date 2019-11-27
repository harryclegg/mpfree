//
//  ViewController.swift
//  mpfree
//
//  Created by Harry Clegg on 22/11/2019.
//  Copyright © 2019 Harry Clegg. All rights reserved.
//

import Cocoa
import iTunesLibrary

class ViewController: NSViewController {
    
    // MARK: - IBOutlet Properties
    @IBOutlet weak var playlistTableView: NSOutlineView!

    // MARK: - Class Properties
    var parser: ITParse = ITParse()
    
    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Do any additional setup after loading the view.
        print("mpfree: Loaded view.")
        
        parser.setTargetTree(rootFolder: "Playlists")

        playlistTableView.delegate = self
        playlistTableView.dataSource = self
    }
    
    override var representedObject: Any? {
        didSet {
            /// Update the view, if already loaded.
        }
    }
    
}

extension ViewController: NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    /// You must give each row a unique identifier, referred to as `item` by the outline view
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            debugPrint(index)
            let switchPoint = parser.targetTree.folders.count
            if index >= switchPoint {
                return parser.targetTree.playlists[index - switchPoint] as Any
            } else {
                return parser.targetTree.folders[index] as Any
            }
        } else if let folder = item as? ITParsePlaylistFolder {
            let switchPoint = folder.folders.count
            if index >= switchPoint {
                return folder.playlists[index - switchPoint] as Any
            } else {
                return folder.folders[index] as Any
            }
        } else if (item as? ITParsePlaylist) != nil {
            return ("playlist", index)
        } else {
            return 0
        }
    }
    
    /// Tell how many children each row has:
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            debugPrint(parser.targetTree.allChildren.count )
            return parser.targetTree.allChildren.count
        } else if let folder = item as? ITParsePlaylistFolder {
            return folder.allChildren.count
        } else {
            return 0
        }
    }
    
    /// Tell whether the row is expandable. The only expandable row is the Hobbies row
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if item is ITParsePlaylistFolder {
            return true
        } else {
            return false
        }
    }
    
    /// Set the text for each row
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let columnIdentifier = tableColumn?.identifier.rawValue else {
            return nil
        }

        var text: String = ""
        
        switch(columnIdentifier) {
            
        case "playlist":
            
            let cell = outlineView.makeView(withIdentifier: .playlist, owner: self) as! CheckboxCellView

            var setState: NSControl.StateValue = NSControl.StateValue.off
            if let playlist = item as? ITParsePlaylist {
                if String(playlist.name).starts(with: "*") {
                    setState = NSControl.StateValue.on
                }
                text = playlist.name
                cell.checkboxButton.allowsMixedState = false
            } else if let folder = item as? ITParsePlaylistFolder {
                if folder.doAnyChildrenStartWithString(string: "*") {
                    setState = NSControl.StateValue.mixed
                }
                text = folder.name
                cell.checkboxButton.allowsMixedState = true
            }
                    
            cell.checkboxButton.state = setState
            cell.checkboxButton.title = text
            return cell

        case "trackCount":
            if let playlist = item as? ITParsePlaylist {
                text = String(playlist.nTracks)
            }
            
            let view = outlineView.makeView(withIdentifier: .trackCount, owner: self) as? NSTableCellView
            view?.textField?.stringValue = text
            return view

        case "outputName":
            if let playlist = item as? ITParsePlaylist {
                text = String(playlist.getOutputName())
            }
            
            let view = outlineView.makeView(withIdentifier: .outputName, owner: self) as? NSTableCellView
            view?.textField?.stringValue = text
            return view
            
        default:
            text = "def"
        }
        
        return nil

    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRow row: Int) -> CGFloat {
        return 32.0
    }
    
}

extension NSUserInterfaceItemIdentifier {
    static let playlist = NSUserInterfaceItemIdentifier(rawValue: "playlistCell")
    static let trackCount = NSUserInterfaceItemIdentifier(rawValue: "trackCountCell")
    static let outputName = NSUserInterfaceItemIdentifier(rawValue: "outputNameCell")
}



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
