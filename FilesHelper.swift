//
//  FilesHelper.swift
//  Player
//
//  Created by zeze on 16/10/14.
//  Copyright © 2016年 zeWill. All rights reserved.
//

import Cocoa

class FilesHelper: NSObject {
    
    lazy var paths: [Song] = {
        return []
    }()
    
    func getMp3URLs() -> [Song] {
        // open
        let openPanel = NSOpenPanel()
        openPanel.prompt = "Select"
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = true
        
        
        if openPanel.runModal() == NSFileHandlingPanelOKButton {
  
            if openPanel.urls.count != 0 {
                let requiredAttributes = [URLResourceKey.localizedNameKey]
                paths.removeAll()
                for path in openPanel.urls{
                    
                    if path.pathExtension != "" {
                        self.insertPath(url: path)
                    }
                    else {
                        if let enumerator = FileManager.default.enumerator(at: path, includingPropertiesForKeys: requiredAttributes, options: [], errorHandler: nil) {
                            while let path = enumerator.nextObject() as? URL {
                                self.insertPath(url: path)
                            }
                        }
                    }
                }
            }
            
           
        }
         return paths
    }
    
    func insertPath(url: URL) {
        do {
            let properties = try  url.resourceValues(forKeys:[.nameKey])
            if url.pathExtension == "mp3" {
                paths.append(Song(name: properties.name  ?? "",
                                  url: url))
            }
        }catch {
            print("error")
        }
    }
}
