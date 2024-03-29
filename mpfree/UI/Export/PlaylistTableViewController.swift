//
//  PlaylistTableViewController.swift
//  mpfree
//
//  Created by Harry Clegg on 22/11/2019.
//  Copyright © 2019 Harry Clegg. All rights reserved.
//

import Cocoa
import iTunesLibrary
import Defaults

/// A enum that represents the list of columns in the outline view. Enum is preferred over
/// string literals as they are checked at compile-time. Repeating the same strings over
/// and over again are error-prone. However, you need to make the Column Identifier in
/// Interface Builder with the raw value used here.
enum PlaylistTableViewColumn: String {
    case playlist = "Playlist"
    case trackCount = "TrackCount"
    case outputPath = "OutputPath"
    
    init?(_ tableColumn: NSTableColumn) {
        self.init(rawValue: tableColumn.identifier.rawValue)
    }
    
    var cellIdentifier: NSUserInterfaceItemIdentifier {
        return NSUserInterfaceItemIdentifier(self.rawValue + "Cell")
    }
}

class PlaylistTableViewController: NSViewController {
    
    // MARK: - IBOutlet Properties
    @IBOutlet weak var outlineView: NSOutlineView!
    
    @IBOutlet weak var rootPlaylistSelector: NSPopUpButton!
    
    var appDelegate: AppDelegate!
    var parser: ITParse!
    
    var startsWith = ""
    var endsWith = ""
    var shouldRemovePrefix = false
    var shouldRemoveSuffix = false
    
    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startsWith = Defaults[.exportFilterPrefixString]
        endsWith = Defaults[.exportFilterSuffixString]
        
        shouldRemovePrefix = Defaults[.exportStripPathPrefix]
        shouldRemoveSuffix = Defaults[.exportStripPathSuffix]
        
        /// Do any additional setup after loading the view.
        print("mpfree: Loaded view.")
        
        appDelegate = (NSApplication.shared.delegate as! AppDelegate)
        parser = appDelegate.parser
        parser.setView(tableView: self)
        parser.generateRootTree(initialRootFolderID: appDelegate.rootFolderID)
        
        outlineView.delegate = self
        outlineView.dataSource = self
    }
    
    override var representedObject: Any? {
        didSet {
            /// Update the view, if already loaded.
        }
    }
}

extension PlaylistTableViewController: NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    /// You must give each row a unique identifier, referred to as `item` by the outline view
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
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
        
        switch item {
        case nil:                               return parser.targetTree.allChildren.count
        case let row as ITParsePlaylistFolder:  return row.allChildren.count
        default:                                return 0
        }
    }
    
    /// Tell whether the row is expandable. The only expandable row is the Hobbies row
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        switch item {
        case is ITParsePlaylistFolder:  return true
        default:                        return false
        }
    }
    
    /// Set the text for each row
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let column = PlaylistTableViewColumn(tableColumn!) else {return nil}
        
        var text: String = ""
        
        switch(column) {
            
        case .playlist:
            let view = outlineView.makeView(withIdentifier: column.cellIdentifier, owner: self) as! CheckboxCellView
            
            switch(item) {
                
            case let playlist as ITParsePlaylist:
                view.checkboxButton.title = playlist.name
                if playlist.isSelected(startsWith: startsWith, endsWith: endsWith) {
                    view.checkboxButton.state = NSControl.StateValue.on
                } else {
                    view.checkboxButton.state = NSControl.StateValue.off
                }
                view.checkboxButton.allowsMixedState = false
                
            case let folder as ITParsePlaylistFolder:
                view.checkboxButton.title = folder.name
                view.checkboxButton.state = folder.getSelectionStatus
                view.checkboxButton.allowsMixedState = folder.anyFilteredChildren
                
            default: break
            }
            
            // Allows us to handle clicking on checkbox
            view.delegate = self
            view.item = item
            return view
            
        case .trackCount:
            let view = outlineView.makeView(withIdentifier: column.cellIdentifier, owner: self) as? NSTableCellView
            
            switch(item) {
                
            case let playlist as ITParsePlaylist:
                view?.textField?.stringValue = "\(playlist.totalItemCount)"

            case let folder as ITParsePlaylistFolder:
                view?.textField?.stringValue = "\(folder.totalItemCount)"

            default: break
            }
            
            return view
            
        case .outputPath:
            if let playlist = item as? ITParsePlaylist {
                text = String(playlist.generateExportPath())
            }
            
            let view = outlineView.makeView(withIdentifier: column.cellIdentifier, owner: self) as? NSTableCellView
            view?.textField?.stringValue = text
            return view
        }
    }
    
    func reloadData() {
        outlineView.reloadData()
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRow row: Int) -> CGFloat {
        return 32.0
    }
    
    
    
}

extension PlaylistTableViewController: CheckboxCellViewDelegate {
    /// A delegate function where we can act on update from the checkbox in the "Is Selected" column
    func checkboxCellView(_ cell: CheckboxCellView, didChangeState state: NSControl.StateValue) {
        
        var newState: SelectionState
        
        // Map checkbox state to selection state.
        switch state {
        case .on:
            newState = .userSelected
        case .off:
            newState = .userDeSelected
        case .mixed:
            newState = .setFromFilters
        default:
            return
        }
        
        switch cell.item {
            
        case let playlist as ITParsePlaylist:
            playlist.setSelection(newState)
            
        case let folder as ITParsePlaylistFolder:
            folder.setSelection(newState)
            // This is more efficient than calling reload on every child since collapsed children are
            // not reloaded. They will be reloaded when they become visible
            outlineView.reloadItem(folder, reloadChildren: true)
            
        default: return
        }
    }
}
