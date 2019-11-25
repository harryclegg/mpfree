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
    
    var parser = iTunesParser()
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        print("mpfree: Loaded view.")

        playlistTableView.delegate = self
        playlistTableView.dataSource = self
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
}

extension ViewController: NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    // You must give each row a unique identifier, referred to as `item` by the outline view
    //   * For top-level rows, we use the values in the `keys` array
    //   * For the hobbies sub-rows, we label them as ("hobbies", 0), ("hobbies", 1), ...
    //     The integer is the index in the hobbies array
    //
    // item == nil means it's the "root" row of the outline view, which is not visible
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            debugPrint(index)
            let switchPoint = parser.playlistTree?.folders.count
            if index >= switchPoint! {
                return parser.playlistTree?.playlists[index - switchPoint!] as Any
            } else {
                return parser.playlistTree?.folders[index] as Any
            }
        } else if let folder = item as? ITLibPlaylistFolder {
            let switchPoint = folder.folders.count
            if index >= switchPoint {
                return folder.playlists[index - switchPoint] as Any
            } else {
                return folder.folders[index] as Any
            }
        } else if (item as? ITLibPlaylist) != nil {
            return ("playlist", index)
        } else {
            return 0
        }
    }
    
    // Tell how many children each row has:
    //    * The root row has 5 children: name, age, birthPlace, birthDate, hobbies
    //    * The hobbies row has how ever many hobbies there are
    //    * The other rows have no children
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            debugPrint(parser.playlistTree?.allChildren.count ?? 0)
            return parser.playlistTree?.allChildren.count ?? 0
        } else if let folder = item as? ITLibPlaylistFolder {
            return folder.allChildren.count
        } else {
            return 0
        }
    }
    
    // Tell whether the row is expandable. The only expandable row is the Hobbies row
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if item is ITLibPlaylistFolder {
            return true
        } else {
            return false
        }
    }
    
    // Set the text for each row
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let columnIdentifier = tableColumn?.identifier.rawValue else {
            return nil
        }

        var text = ""

        switch(columnIdentifier) {
        case "nameColumn":
            if let folder = item as? ITLibPlaylistFolder {
                text = folder.name!
            } else if let playlist = item as? ITLibPlaylist {
                text = playlist.name
            }
        case "nChildrenColumn":
            if item is ITLibPlaylistFolder {
                text = ""
            } else if let playlist = item as? ITLibPlaylist {
                text = String(playlist.items.count)
            }
        default:
            text = "def"
        }
        
        let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "outlineViewCell"), owner: self) as? NSTableCellView
        cell?.textField?.stringValue = text

        return cell
    }
    
}
