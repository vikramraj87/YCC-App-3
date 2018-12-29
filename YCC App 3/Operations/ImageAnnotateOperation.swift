//
//  ImageAnnotateOperation.swift
//  YCC App 3
//
//  Created by Vikram Raj Gopinathan on 23/12/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Cocoa

class ImageAnnotateOperation: Operation {
    var inputImage: NSImage?
    
    let text: String
    let color: CodeColor
    let position: CodePosition
    
    fileprivate var _annotatedImage: NSImage?
    
    init(text: String, color: CodeColor, position: CodePosition) {
        self.text = text
        self.color = color
        self.position = position
    }
    
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
        
        guard let imageToAnnotate = img else { return }
        
        _annotatedImage = imageToAnnotate.drawText(text, postion: position, color: color)
    }
}

extension ImageAnnotateOperation: ImageProvider {
    var image: NSImage? {
        return _annotatedImage
    }
}
