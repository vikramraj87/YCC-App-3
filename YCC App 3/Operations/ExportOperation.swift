//
//  ExportOperation.swift
//  YCC App 3
//
//  Created by Vikram Raj Gopinathan on 09/01/19.
//  Copyright © 2019 Vikram Raj Gopinathan. All rights reserved.
//

import Cocoa

class ExportOperation: Operation {
    var jewelImage: JewelImageProtocol
    let editedFolder: URL
    let blackListedFolder: URL
    
    init(jewelImage: JewelImageProtocol, editedFolder: URL, blackListedFolder: URL) {
        self.jewelImage = jewelImage
        self.editedFolder = editedFolder
        self.blackListedFolder = blackListedFolder
    }
    
    override func main() {
        if self.isCancelled { return }
        
        guard jewelImage.state == .whiteListed || jewelImage.state == .blackListed else { return }
        
        let destFolder = jewelImage.state == .whiteListed ? editedFolder : blackListedFolder
        let fileName = jewelImage.originalURL.lastPathComponent
        let destURL = destFolder.appendingPathComponent(fileName)
        
        guard let image = jewelImage.imageToExport else { return }
        
        do {
            try image.writeJPEG(to: destURL)
        } catch {
            print(error)
        }
        
        
        jewelImage.state = .exported
    }
}

extension JewelImageProtocol {
    var imageToExport: NSImage? {
        switch state {
        case .whiteListed:
            if let annotatedURL = annotatedURL {
                return NSImage(contentsOf: annotatedURL)
            } else {
                return nil
            }
        case .blackListed:
            return NSImage(contentsOf: originalURL)
        default:
            return nil
        }
    }
}
