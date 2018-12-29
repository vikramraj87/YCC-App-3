//
//  ImageResizeOperation.swift
//  YCC App 3
//
//  Created by Vikram Raj Gopinathan on 04/12/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Cocoa

protocol ImageURLProvider {
    var imageURL: URL? { get }
}

class ImageResizeOperation: Operation {
    var imageURL: URL?
    
    let maxDimension: CGFloat
    
    fileprivate var _image: NSImage?
    
    init(maxDimension: CGFloat) {
        self.maxDimension = maxDimension
    }
    
    override func main() {
        if isCancelled { return }
        
        let url: URL?
        if let imageURL = imageURL {
            url = imageURL
        } else {
            let imageURLProvider = dependencies
                .filter { $0 is ImageURLProvider }
                .first as? ImageURLProvider
            url = imageURLProvider?.imageURL
        }
        
        if isCancelled { return }
        
        guard let strongImageURL = url else { return }
        
        _image = ImageDownSampler.downsample(imageAt: strongImageURL,
                                            to: maxDimension)
    }
    
    
}


extension ImageResizeOperation: ImageProvider {
    var image: NSImage? {
        return _image
    }
}
