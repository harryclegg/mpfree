//
//  iTunesParser.swift
//  mpfree
//
//  Created by Harry Clegg on 23/11/2019.
//  Copyright © 2019 Harry Clegg. All rights reserved.
//

import Cocoa
import iTunesLibrary
import Foundation

class iTunesParser {
    
    // Store the iTunes library object.
    var library: ITLibrary?
    var playlists: Array<ITLibPlaylist> = Array()
    var playlistTree: ITLibPlaylistFolder?
    
    init() {
        
        // Try to read the iTunes library.
        do {
            try self.library = ITLibrary.init(apiVersion: "1.0")
        } catch let error {
            print("Error: \(error)")
        }
        
        self.playlists = self.library!.allPlaylists
        
        
        self.removeDistinguishedPlaylists()
        
        self.playlistTree = self.formPlaylistsIntoTree()
    }
    
    func removeDistinguishedPlaylists() {
        self.playlists = self.playlists.filter({!$0.isMaster})
        self.playlists = self.playlists.filter({$0.distinguishedKind == ITLibDistinguishedPlaylistKind.kindNone})
    }
    
    func formPlaylistsIntoTree() -> ITLibPlaylistFolder {
        return ITLibPlaylistFolder(playlistArray: self.playlists)
    }
    
    
}


class ITLibPlaylistFolder {
    
    private(set) var name: String?
    private(set) var isRoot: Bool = false
    
    private(set) var persistentID: NSNumber?
    private(set) var asPlaylist: ITLibPlaylist?
    
    private(set) weak var parent: ITLibPlaylistFolder?
    
    private(set) var allChildren: [ITLibPlaylist] = []
    private(set) var playlists: [ITLibPlaylist] = []
    private(set) var regularPlaylists: [ITLibPlaylist] = []
    private(set) var smartPlaylists: [ITLibPlaylist] = []
    private(set) var folders: [ITLibPlaylistFolder] = []
    
    
    init(playlistArray: Array<ITLibPlaylist>) {
        // If this constructor is used, then we are the root playlist folder.
        self.isRoot = true
        
        self.iterateOverPlaylistArray(playlistArray: playlistArray)
    }
    
    init(playlistArray: Array<ITLibPlaylist>, name: String, persistentID: NSNumber, playlistObject: ITLibPlaylist, parent: ITLibPlaylistFolder) {
        self.name = name
        
        // If this constructor is used, then we are not the root playlist folder.
        self.isRoot = false
        self.persistentID = persistentID
        self.parent = parent
        self.asPlaylist = playlistObject
        
        self.iterateOverPlaylistArray(playlistArray: playlistArray)
    }
    
    func iterateOverPlaylistArray(playlistArray: Array<ITLibPlaylist>) {
        for p in playlistArray.filter({($0.parentID == self.persistentID)}) {
            switch p.kind {
                
            case ITLibPlaylistKind.folder:
                self.addFolder(folder: ITLibPlaylistFolder(playlistArray: playlistArray, name: p.name, persistentID: p.persistentID, playlistObject: p, parent: self))
                
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
        regularPlaylists.append(playlist)
        playlists.append(playlist)
        allChildren.append(playlist)
    }
    
    func addSmartPlaylist(playlist: ITLibPlaylist) {
        smartPlaylists.append(playlist)
        playlists.append(playlist)
        allChildren.append(playlist)
    }
    
    func addFolder(folder: ITLibPlaylistFolder) {
        folders.append(folder)
        if (folder.asPlaylist != nil) {
            allChildren.append(folder.asPlaylist!)
        }
    }
    
}
