//
//  FileManager+contentsOfFolder.swift
//  YCC App 3
//
//  Created by Vikram Raj Gopinathan on 28/11/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Foundation

extension FileManager {
    func isFolder(_ url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        guard fileExists(atPath: url.path, isDirectory: &isDirectory) else {
            return false
        }
        return isDirectory.boolValue
    }
    
    func contents(of folderURL: URL) -> [URL] {
        guard isFolder(folderURL) else {
            return []
        }
        do {
            let contents = try contentsOfDirectory(atPath: folderURL.path)
            return contents.map { file in
                return folderURL.appendingPathComponent(file)
            }
        } catch {
            print(error)
            return []
        }
    }
    
    func contents(of folderURL: URL, withExtensions extensions: [String]) -> [URL] {
        let allowedExtensions = extensions.map {
            return $0.lowercased()
            
        }
        return contents(of: folderURL).filter { fileURL in
            return allowedExtensions.contains(fileURL.pathExtension.lowercased())
        }
    }
}
