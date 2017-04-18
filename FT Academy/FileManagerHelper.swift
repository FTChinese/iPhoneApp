//
//  FileManagerHelper.swift
//  FT中文网
//
//  Created by Oliver Zhang on 2017/4/17.
//  Copyright © 2017年 Financial Times Ltd. All rights reserved.
//

import Foundation
struct FileManagerHelper {
    public func removeFiles(_ fileTypes: [String]){
        if let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                // Get the directory contents urls (including subfolders urls)
                let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
                // print(directoryContents)
                
                // if you want to filter the directory contents you can do like this:
                let creativeTypes = fileTypes
                let creativeFiles = directoryContents.filter{ creativeTypes.contains($0.pathExtension) }
                
                for creativeFile in creativeFiles {
                    // print(creativeFile.lastPathComponent)
                    let creativeFileString = creativeFile.lastPathComponent
                    try FileManager.default.removeItem(at: creativeFile)
                    print("remove file from documents folder: \(creativeFileString)")
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
}
