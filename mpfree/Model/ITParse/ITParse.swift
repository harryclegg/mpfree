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

import OutcastID3

class ITParse {
    
    // Store the iTunes library object.
    let library: ITLibrary
    let playlists: Array<ITLibPlaylist>
    
    private(set) var rootTree: ITParsePlaylistFolder!
    private(set) var targetTree: ITParsePlaylistFolder!
    
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
            
            var startsWith = Defaults[.exportFilterPrefixString]
            var endsWith = Defaults[.exportFilterPostfixString]

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
            guard let destFolderURL = exportURL.createAndChangeToFolder(playlist.getOutputName(shouldRemovePrefix: false, prefixToRemove: "")) else {
                continue
            }
            let playlistItems = playlist.asPlaylist.items
            
            var itemCount = 1
            
            for item in playlistItems {
                if let location = item.location {
                    self.exportItem(itemCount: itemCount, itemURL: location, exportURL: destFolderURL)
                }
                itemCount += 1
            }
            
        }
    }
    
    func exportItem(itemCount: Int, itemURL: URL, exportURL: URL) {
        var frameValues: [String: String]
        
        do {
            // Try to read the tag.
            let x = try OutcastID3.MP3File(localUrl: itemURL)
            let tag = try x.readID3Tag()
            
            frameValues = getDesiredFrames(tag: tag.tag, desiredFrames: ["TIT2", "TALB", "TPE1", "TBPM", "TKEY"])
        } catch {
            debugPrint(error)
            return
        }
        

        
        do {
            let fileName = String(format: "%d-%@-%@-%@.mp3", itemCount, ITParse.extractTag(frameValues, "TKEY"), ITParse.extractTag(frameValues, "TIT2"), ITParse.extractTag(frameValues, "TPE1"))
            let destPath = String(format: "%@/%@", exportURL.path, fileName)
            
            if FileManager.default.fileExists(atPath: destPath){
                do {
                    try FileManager.default.removeItem(atPath: destPath)
                } catch {
                    debugPrint(error)
                    return
                }
            }
            
            try FileManager.default.copyItem(atPath: itemURL.path, toPath: destPath)
            
        } catch {
            debugPrint(error)
            return
        }
    }
    
    static func extractTag(_ frameValues: [String: String], _ targetKey: String) -> String {
        var extractedTag = (frameValues[targetKey] ?? "_")
        extractedTag.removingRegexMatches(pattern: "[^A-Za-z0-9 \\_\\-(\\)\\[\\]]+", replaceWith: "_")
        return extractedTag
    }
    
    func getDesiredFrames(tag: OutcastID3.ID3Tag, desiredFrames: [String]) -> [String: String] {
        
        let debugPrintTags = false
        
        var frameDictionary = desiredFrames.reduce(into: [String: String]()) { $0[$1] = "" }
        
        for frame in tag.frames {
            switch frame {
            case let s as OutcastID3.Frame.StringFrame:
                let k = s.type.rawValue
                if frameDictionary[k] != nil {
                    frameDictionary[k] = s.str
                }
                if debugPrintTags {
                    print("\(s.type.description): \(s.str)")
                }
            default:
                break
            }
        }
        
        return frameDictionary
    }
    
    func outputTag(tag: OutcastID3.ID3Tag) {
        for frame in tag.frames {
            switch frame {
            case let s as OutcastID3.Frame.StringFrame:
                print("\(s.type.description): \(s.str)")
                
            case let u as OutcastID3.Frame.UrlFrame:
                print("\(u.type.description): \(u.urlString)")
                
            case let comment as OutcastID3.Frame.CommentFrame:
                print("COMMENT: \(comment)")
                
            case let transcription as OutcastID3.Frame.TranscriptionFrame:
                print("TRANSCRIPTION: \(transcription)")
                
            case let picture as OutcastID3.Frame.PictureFrame:
                print("PICTURE: \(picture)")
                
            case let f as OutcastID3.Frame.ChapterFrame:
                print("CHAPTER: \(f)")
                
            case let toc as OutcastID3.Frame.TableOfContentsFrame:
                print("TOC: \(toc)")
                
            case let rawFrame as OutcastID3.Frame.RawFrame:
                print("Unrecognised frame: \(String(describing: rawFrame.frameIdentifier))")
                
            default:
                break
            }
        }
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
