//
//  ITParsePlaylist.swift
//  mpfree
//
//  Created by Harry Clegg on 05/12/2019.
//  Copyright © 2019 Harry Clegg. All rights reserved.
//

import Cocoa
import iTunesLibrary

class ITParsePlaylist : NSObject {
    
    private(set) var name: String
    private(set) var asPlaylist: ITLibPlaylist
    private(set) var isSmart: Bool = false
    private(set) var nTracks: Int = 0
    
    private(set) var parent: ITParsePlaylistFolder
    private(set) var parser: ITParse
    
    private(set) var manualSelection: Bool = false
    private(set) var manualSelectionState: Bool = false
        
    init(playlist: ITLibPlaylist, parent: ITParsePlaylistFolder, parser: ITParse) {
        self.asPlaylist = playlist
        self.parent = parent
        self.parser = parser
        
        self.name = playlist.name
        self.nTracks = playlist.items.count
                
        self.isSmart = (playlist.kind == ITLibPlaylistKind.smart)
        
    }
    
    func isSelected(startsWith: String, endsWith: String) -> Bool {
        if manualSelection {
            return manualSelectionState
        } else {
            return (startsWith.isEmpty || name.hasPrefix(startsWith)) &&
                (endsWith.isEmpty || name.hasSuffix(endsWith))
        }
    }
    
    func setSelection(_ state: Bool) {
        manualSelection = true
        manualSelectionState = state
    }
    
    func resetSelection() {
        manualSelection = false
    }
    
    func getOutputName() -> String {
        var p = self.parent
        var outputName: String = name
        
        // Build name path by recursing up the playlist tree.
        while !(p.isTarget) {
            outputName = (p.name+"."+outputName)
            p = p.parent!
        }
        return outputName
    }
    
}
