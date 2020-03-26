//
//  ITParsePlaylistFolder.swift
//  mpfree
//
//  Created by Harry Clegg on 05/12/2019.
//  Copyright © 2019 Harry Clegg. All rights reserved.
//

import Cocoa
import iTunesLibrary
import Defaults

class ITParsePlaylistFolder: NSObject {
    
    private(set) var name: String = ""
    private(set) var isRoot: Bool = false
    
    private(set) var persistentID: NSNumber?
    private(set) var asPlaylist: ITLibPlaylist?
    
    private(set) var parent: ITParsePlaylistFolder?
    private(set) var parser: ITParse!
    
    private(set) var allChildren: [ITLibPlaylist] = []
    
    private(set) var playlists: [ITParsePlaylist] = []
    private(set) var regularPlaylists: [ITParsePlaylist] = []
    private(set) var smartPlaylists: [ITParsePlaylist] = []
    private(set) var folders: [ITParsePlaylistFolder] = []
    
    private(set) var allFolders: [ITParsePlaylistFolder] = []

    var isTarget: Bool = false
    
    init(playlistArray: Array<ITLibPlaylist>, parser: ITParse) {
        super.init()

        // If this constructor is used, then we are the root playlist folder.
        self.isRoot = true
        
        // By default it's also the target
        self.isTarget = true
        
        self.parser = parser
        
        self.iterateOverPlaylistArray(playlistArray: playlistArray)
    }
    
    init(playlistArray: Array<ITLibPlaylist>, name: String, persistentID: NSNumber, asPlaylist: ITLibPlaylist, parent: ITParsePlaylistFolder, parser: ITParse) {
        super.init()
        
        self.name = name
        
        // If this constructor is used, then we are not the root playlist folder.
        self.isRoot = false
        self.persistentID = persistentID
        self.parent = parent
        self.parser = parser
        self.asPlaylist = asPlaylist
        
        self.iterateOverPlaylistArray(playlistArray: playlistArray)
    }
    
    func iterateOverPlaylistArray(playlistArray: Array<ITLibPlaylist>) {
        
        for p in playlistArray.filter({($0.parentID == self.persistentID)}) {
            switch p.kind {
                
            case ITLibPlaylistKind.folder:
                self.addFolder(folder: ITParsePlaylistFolder(playlistArray: playlistArray, name: p.name, persistentID: p.persistentID, asPlaylist: p, parent: self, parser: self.parser))
                
            case ITLibPlaylistKind.regular:
                self.addRegularPlaylist(playlist: p)
                
            case ITLibPlaylistKind.smart:
                self.addSmartPlaylist(playlist: p)
                
            default:
                debugPrint(p)
            }
        }
    }
    
    func addRegularPlaylist(playlist: ITLibPlaylist) {
        let itParsePlaylist = ITParsePlaylist(playlist: playlist, parent: self, parser: self.parser)
        regularPlaylists.append(itParsePlaylist)
        playlists.append(itParsePlaylist)
        allChildren.append(playlist)
    }
    
    func addSmartPlaylist(playlist: ITLibPlaylist) {
        let itParsePlaylist = ITParsePlaylist(playlist: playlist, parent: self, parser: self.parser)
        smartPlaylists.append(itParsePlaylist)
        playlists.append(itParsePlaylist)
        allChildren.append(playlist)
    }
    
    func addFolder(folder: ITParsePlaylistFolder) {
        folders.append(folder)
        allFolders.append(folder)
        allFolders += folder.folders
        if (folder.asPlaylist != nil) {
            allChildren.append(folder.asPlaylist!)
        }
    }
    
    func getSelectionStatus() -> NSControl.StateValue {
        var anyChildrenSelected = false
        var allChildrenSelected = true
        
        let startsWith = Defaults[.exportFilterPrefixString]
        let endsWith = Defaults[.exportFilterPostfixString]
        
        for folder in self.folders {
            if folder.getSelectionStatus() == .on {
                anyChildrenSelected = true
            } else {
                allChildrenSelected = false
            }
        }
        
        for playlist in self.playlists {

            if playlist.isSelected(startsWith: startsWith, endsWith: endsWith) {
                anyChildrenSelected = true
            } else {
                allChildrenSelected = false
            }
        }
        
        if anyChildrenSelected {
            if allChildrenSelected {
                return .on
            } else {
                return .mixed
            }
        } else {
            return .off
        }
        
    }
    
    func setSelection(_ isSelected: Bool) {
        self.folders.forEach { $0.setSelection(isSelected) }
        self.playlists.forEach { $0.setSelection(isSelected) }
    }
    
    
    
}
