//
//  ImageResizeOperation.swift
//  YCC App 3
//
//  Created by Vikram Raj Gopinathan on 04/12/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Cocoa

protocol ResizedImageProvider {
    var resizedImage: NSImage? { get }
}

class ImageResizeOperation: Operation, ResizedImageProvider {
    let originalImageURL: URL
    let maxDimension: CGFloat
    
    private var _resizedImage: NSImage?
    var resizedImage: NSImage? {
        return _resizedImage
    }
    
    init(originalImageURL: URL, maxDimension: CGFloat) {
        self.originalImageURL = originalImageURL
        self.maxDimension = maxDimension
    }
    
    override func main() {
        if isCancelled { return }
        
        let cgImage = ImageDownSampler.downsample(imageAt: originalImageURL,
                                                  to: maxDimension)
        
        if isCancelled { return }
        
        let nsImage = NSImage(cgImage: cgImage, size: .zero)
        _resizedImage = nsImage
    }
}
