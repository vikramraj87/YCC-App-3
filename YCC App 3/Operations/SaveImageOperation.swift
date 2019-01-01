//
//  SaveImageOperation.swift
//  YCC App 3
//
//  Created by Vikram Raj Gopinathan on 31/12/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Cocoa

class SaveImageOperation: Operation {
    var inputImage: NSImage?
    
    var savedURL: URL?
    
    override func main() {
        if isCancelled { return }
        
        let img: NSImage?
        if let inputImage = inputImage {
            img = inputImage
        } else {
            let imageProvider = dependencies
                .filter { $0 is ImageProvider }
                .first as? ImageProvider
            img = imageProvider?.image
        }
        
        if isCancelled { return }
        
        guard let imageToSave = img else { return }
        
        let url = uniqueURL()
        
        do {
            try imageToSave.writeJPEG(to: url)
        } catch {
            print(error)
        }
        savedURL = url
    }
    
    private func uniqueURL() -> URL {
        let appId = Bundle.main.bundleIdentifier!
        let cachesDirectory = FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(appId)
        let fileName = UUID().uuidString
        let url = cachesDirectory
            .appendingPathComponent(fileName)
            .appendingPathExtension("jpg")
        return url
    }
}

extension SaveImageOperation: ImageURLProvider {
    var imageURL: URL? {
        return savedURL
    }
}
