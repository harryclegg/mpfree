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
import Defaults

enum SelectionState: Int {
    case userDeSelected = 0
    case setFromFilters = 1
    case userSelected = 2
}

struct ItemMetadata {
    var title: String
    var artist: String
    var BPM: Int
}

class ITParse {
    
    // Store the iTunes library object.
    let library: ITLibrary
    let playlists: Array<ITLibPlaylist>
    
    private(set) var rootTree: ITParsePlaylistFolder!
    private(set) var targetTree: ITParsePlaylistFolder!
    
    private(set) var tableView: PlaylistTableViewController?
    
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
    }
    
    func setView(tableView: PlaylistTableViewController) {
        self.tableView = tableView
    }
    
    func redrawTree() {
        self.tableView!.reloadData()
        
    }
    
    func generateRootTree(initialRootFolderID: UInt64) {
        self.rootTree = ITParsePlaylistFolder(playlistArray: playlists, parser: self)
        self.targetTree = self.rootTree
        self.setTargetTree(rootFolderID: initialRootFolderID)
    }
    
    func setTargetTree(rootFolderID: UInt64) {
        self.targetTree.isTarget = false
        
        func recurse(target: ITParsePlaylistFolder) -> ITParsePlaylistFolder? {
            for p in target.folders {
                if p.persistentID == rootFolderID as NSNumber {
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
            // Backup default value - show all.
            self.targetTree = self.rootTree
        }
        
        self.targetTree.isTarget = true
    }
    
    func findAllPlaylists(topFolder: ITParsePlaylistFolder, selectedOnly: Bool) -> [ITParsePlaylist] {
        
        var allPlaylists: [ITParsePlaylist] = topFolder.playlists
        
        if selectedOnly {
            
            let startsWith = Defaults[.exportFilterPrefixString]
            let endsWith = Defaults[.exportFilterSuffixString]

            allPlaylists = allPlaylists.filter({$0.isSelected(startsWith: startsWith, endsWith: endsWith)})
        }
        
        for folder in topFolder.folders {
            allPlaylists += self.findAllPlaylists(topFolder: folder, selectedOnly: selectedOnly)
        }
        
        return allPlaylists
    }
    
    
    func exportPlaylists(exportURL: URL) {
        
        print("mpfree: Exporting playlists to folder '", exportURL.path, "'.")
        
        let targetPlaylists = self.findAllPlaylists(topFolder: self.targetTree, selectedOnly: true)
        
        for playlist in targetPlaylists {
            guard let destFolderURL = exportURL.createAndChangeToFolder(playlist.generateExportPath()) else {
                continue
            }
            let playlistItems = playlist.asPlaylist.items
            
            var itemCount = 1
            
            for item in playlistItems {
                self.exportItem(itemCount: itemCount, item: item, exportURL: destFolderURL)
                itemCount += 1
            }
            
        }
    }
    
    func exportItem(itemCount: Int, item: ITLibMediaItem, exportURL: URL) {
        // Export an iTunes media item to the desired export URL.
        
        // Get track metadata.
        let metadata = getItemMetadata(item: item)
        
        // Try and grab the URL of the track.
        guard let itemLocation = item.location else {
            return
        }

        do {
            // Format output paths.
            let fileName = String(format: "%02d-%@-%@.%@", itemCount, metadata.title, metadata.artist, itemLocation.pathExtension)
            let destPath = String(format: "%@/%@", exportURL.path, fileName)
            
            // Try and delete if file with same name already exists.
            if FileManager.default.fileExists(atPath: destPath){
                do {
                    try FileManager.default.removeItem(atPath: destPath)
                } catch {
                    debugPrint(error)
                    return
                }
            }
            
            // Try to copy the item from source to dest.
            try FileManager.default.copyItem(atPath: itemLocation.path, toPath: destPath)
            
        } catch {
            debugPrint(error)
            return
        }
    }
    
    func getItemMetadata(item: ITLibMediaItem) -> ItemMetadata {
        // Extract the metadata required to form the output file name from the iTunes item.
        
        // Unwrap the artist from the item, requrires default.
        let artist = item.artist?.name ?? "UNKNOWN"
        
        // Grab the obvious ones directly.
        return ItemMetadata(title: item.title, artist: artist, BPM: item.beatsPerMinute)
    }
    
}


extension URL {
    
    /// Appends each item in the array as a component to the existing URL.
    func appendingManyPathComponents(_ components: [String]) -> URL {
        // Append multiple path components in a single call to prevent long lines of multiple calls.
        var result = self
        components.filter {
            // Filter out any empty strings.
            !$0.isEmpty
        }.forEach {
            // Add the non-empty strings.
            result.appendPathComponent($0)
        }
        return result
    }

    func createAndChangeToFolder(_ folderPath: String) -> URL? {
        
        let pathComponents = folderPath.components(separatedBy: "/")
        let newFolderPath = self.appendingManyPathComponents(pathComponents)
        
        let fileManager = FileManager.default
        do {
            try fileManager.createDirectory(atPath: newFolderPath.path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            return nil
        }
        
        return newFolderPath
        
    }
}

extension String {
    mutating func removingRegexMatches(pattern: String, replaceWith: String = "") {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            let range = NSMakeRange(0, self.count)
            self = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replaceWith)
        } catch {
            return
        }
    }
}
