//
//  ImageResizeOperation.swift
//  YCC App 3
//
//  Created by Vikram Raj Gopinathan on 04/12/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Cocoa

class ImageResizeOperation: Operation {
    let originalImageURL: URL
    let maxDimension: CGFloat
    
    fileprivate var _resizedImage: NSImage?
    
    init(originalImageURL: URL, maxDimension: CGFloat) {
        self.originalImageURL = originalImageURL
        self.maxDimension = maxDimension
    }
    
    override func main() {
        if isCancelled { return }
        
        _resizedImage = ImageDownSampler.downsample(imageAt: originalImageURL,
                                                    to: maxDimension)
    }
}

extension ImageResizeOperation: ResizedImageProvider {
    var resizedImage: NSImage? {
        return _resizedImage
    }
}
