//
//  DisplayImageOperation.swift
//  YCC App 3
//
//  Created by Vikram Raj Gopinathan on 08/12/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Cocoa

protocol ImageURLProvider {
    var imageURL: URL? { get }
}

class DisplayImageOperation: Operation {
    var image: NSImage?
    
    fileprivate let imageView: NSImageView
    
    init(imageView: NSImageView) {
        self.imageView = imageView
    }
    
    override func main() {
        if isCancelled { return }
        
        let img: NSImage?
        if let image = image {
            img = image
        } else {
            let resizedImageProvider = dependencies
                .filter { $0 is ResizedImageProvider }
                .first as? ResizedImageProvider
            img = resizedImageProvider?.resizedImage
        }
        
        if isCancelled { return }
        
        imageView.image = img
    }
}
