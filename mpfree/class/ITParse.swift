//
//  ITParse.swift
//  mpfree
//
//  Created by Harry Clegg on 23/11/2019.
//  Copyright © 2019 Harry Clegg. All rights reserved.
//

import Cocoa
import iTunesLibrary
import Foundation

class ITParse {
    
    // Store the iTunes library object.
    let library: ITLibrary
    let playlists: Array<ITLibPlaylist>
    let rootTree: ITParsePlaylistFolder
    
    private(set) var rootFolder: String = ""
    private(set) var targetTree: ITParsePlaylistFolder
    
    init() {
        
        
        var lib: ITLibrary?
        // Try to read the iTunes library.
        do {
            try lib = ITLibrary.init(apiVersion: "1.0")
        } catch let error {
            print("Error: \(error)")
        }
        
        self.library = lib!
        var playlists = self.library.allPlaylists
        
        // Remove distinguished kinds.
        playlists = playlists.filter({!$0.isMaster})
        playlists = playlists.filter({$0.distinguishedKind == ITLibDistinguishedPlaylistKind.kindNone})
        self.playlists = playlists
        
        self.rootTree = ITParsePlaylistFolder(playlistArray: playlists)
        self.targetTree = self.rootTree
        
    }
    
    func setTargetTree(rootFolder: String) {
        self.targetTree.isTarget = false
        
        func recurse(target: ITParsePlaylistFolder) -> ITParsePlaylistFolder? {
            for p in target.folders {
                if p.name == rootFolder {
                    return p
                }
                if let target = recurse(target: p) {
                    return target
                }
            }
            return nil
        }
        
        if let targetTree = recurse(target: self.rootTree) {
            self.targetTree = targetTree

        } else {
            if rootFolder != "" {
                // ERROR!
            }
            // Backup default value - show all.
            self.targetTree = self.rootTree
        }
        
        self.targetTree.isTarget = true
    }
}

class ITParsePlaylist {
    
    private(set) var name: String
    private(set) var asPlaylist: ITLibPlaylist
    private(set) var isSmart: Bool = false
    private(set) var nTracks: Int = 0
    private(set) var parent: ITParsePlaylistFolder
    
    init(playlist: ITLibPlaylist, parent: ITParsePlaylistFolder) {
        self.asPlaylist = playlist
        self.parent = parent
        self.name = playlist.name
        self.nTracks = playlist.items.count
        
        self.isSmart = (playlist.kind == ITLibPlaylistKind.smart)
        
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

class ITParsePlaylistFolder {
    
    private(set) var name: String = ""
    private(set) var isRoot: Bool = false
    
    private(set) var persistentID: NSNumber?
    private(set) var asPlaylist: ITLibPlaylist?
    
    private(set) weak var parent: ITParsePlaylistFolder?
    
    private(set) var allChildren: [ITLibPlaylist] = []
    
    private(set) var playlists: [ITParsePlaylist] = []
    private(set) var regularPlaylists: [ITParsePlaylist] = []
    private(set) var smartPlaylists: [ITParsePlaylist] = []
    private(set) var folders: [ITParsePlaylistFolder] = []
    
    private(set) var allFolders: [ITParsePlaylistFolder] = []
    
    var isTarget: Bool = false
    
    init(playlistArray: Array<ITLibPlaylist>) {
        // If this constructor is used, then we are the root playlist folder.
        self.isRoot = true
        
        // By default it's also the target
        self.isTarget = true
        
        self.iterateOverPlaylistArray(playlistArray: playlistArray)
    }
    
    init(playlistArray: Array<ITLibPlaylist>, name: String, persistentID: NSNumber, asPlaylist: ITLibPlaylist, parent: ITParsePlaylistFolder) {
        self.name = name
        
        // If this constructor is used, then we are not the root playlist folder.
        self.isRoot = false
        self.persistentID = persistentID
        self.parent = parent
        self.asPlaylist = asPlaylist
        
        self.iterateOverPlaylistArray(playlistArray: playlistArray)
    }
    
    func iterateOverPlaylistArray(playlistArray: Array<ITLibPlaylist>) {
        
        for p in playlistArray.filter({($0.parentID == self.persistentID)}) {
            switch p.kind {
                
            case ITLibPlaylistKind.folder:
                self.addFolder(folder: ITParsePlaylistFolder(playlistArray: playlistArray, name: p.name, persistentID: p.persistentID, asPlaylist: p, parent: self))
                
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
        let itParsePlaylist = ITParsePlaylist(playlist: playlist, parent: self)
        regularPlaylists.append(itParsePlaylist)
        playlists.append(itParsePlaylist)
        allChildren.append(playlist)
    }
    
    func addSmartPlaylist(playlist: ITLibPlaylist) {
        let itParsePlaylist = ITParsePlaylist(playlist: playlist, parent: self)
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
    
    func doAnyChildrenStartWithString(string: String) -> Bool {
        
        for p in self.playlists {
            if p.name.starts(with: string) {
                return true;
            }
        }
        
        for f in self.folders {
            if f.doAnyChildrenStartWithString(string: string) {
                return true
            }
        }
        
        return false
        
    }
    
}
