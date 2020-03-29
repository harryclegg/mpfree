//
//  ITParsePlaylist.swift
//  mpfree
//
//  Created by Harry Clegg on 05/12/2019.
//  Copyright © 2019 Harry Clegg. All rights reserved.
//

import Cocoa
import iTunesLibrary
import Defaults

class ITParsePlaylist : NSObject {
    
    // Private variables are not changeable from outside this class.
    private(set) var name: String
    private(set) var asPlaylist: ITLibPlaylist
    private(set) var isSmart: Bool = false
    private(set) var nTracks: Int = 0
    
    private(set) var parent: ITParsePlaylistFolder
    private(set) var parser: ITParse
    
    private(set) var selectionState: SelectionState = .setFromFilters

    init(playlist: ITLibPlaylist, parent: ITParsePlaylistFolder, parser: ITParse) {
        self.asPlaylist = playlist
        self.parent = parent
        self.parser = parser
        
        self.name = playlist.name
        self.nTracks = playlist.items.count
                
        self.isSmart = (playlist.kind == ITLibPlaylistKind.smart)
    }
        
    func shouldBeFiltered(startsWith: String, endsWith: String) -> Bool {
        // Parse playlist name validity using start and end filters.
        return (startsWith.isEmpty || name.hasPrefix(startsWith)) &&
            (endsWith.isEmpty || name.hasSuffix(endsWith))
    }
    
    func shouldBeFiltered() -> Bool {
        // Grabs the current start and end strings from persistent data then calls the filter function with those.
        let startsWith = Defaults[.exportFilterPrefixString]
        let endsWith = Defaults[.exportFilterPostfixString]
        return shouldBeFiltered(startsWith: startsWith, endsWith: endsWith)
    }
    
    func setSelection(_ newState: SelectionState) {
        // Apply a new selection state to this playlist.
        selectionState = newState;
    }
    
    func isSelected() -> Bool {
        // Grabs the current start and end strings from persistent data then calls the selection function with those.
        let startsWith = Defaults[.exportFilterPrefixString]
        let endsWith = Defaults[.exportFilterPostfixString]
        return isSelected(startsWith: startsWith, endsWith: endsWith)
    }
    
    func isSelected(startsWith: String, endsWith: String) -> Bool {
        // Return if the current playlist is selected.
        switch selectionState {
        case .userSelected:
            return true
            
        case .userDeSelected:
            return false
            
        case .setFromFilters:
            return shouldBeFiltered()
        }
    }
    
    func getOutputName(shouldRemovePrefix: Bool, prefixToRemove: String) -> String {
        var p = self.parent
        var outputName: String = name
        
        // Remove prefix if supposed to.
        if shouldRemovePrefix {
            outputName = outputName.deletePrefix(prefixToRemove)
        }
        
        // Build name path by recursing up the playlist tree.
        while !(p.isTarget) {
            outputName = (p.name+"."+outputName)
            p = p.parent!
        }
        return outputName
    }
    
}

extension String {
    func deletePrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}
