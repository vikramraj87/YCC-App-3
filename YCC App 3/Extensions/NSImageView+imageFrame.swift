//
//  NSImageView+imageFrame.swift
//  YCC App 3
//
//  Created by Vikram Raj Gopinathan on 24/11/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Cocoa

extension NSImageView {
    // Incomplete implementation
    // Not the image alignment and scale are taken into consideration
    // for the purpose of the app
    var imageFrame: CGRect? {
        guard let image = image else {
            return nil
            
        }
        
        var iFrame = self.bounds
        
        // Inset image bounds according to framestyle
        switch self.imageFrameStyle {
        case .button,
             .groove:
            iFrame = iFrame.insetBy(dx: 2, dy: 2)
        case .photo:
            iFrame.origin.x += 1
            iFrame.origin.y += 2
            iFrame.size.width -= 3
            iFrame.size.height -= 3
        case .grayBezel:
            iFrame = iFrame.insetBy(dx: 8, dy: 8)
        default:
            break
        }
        
        // When image size is smaller than view size inset(ted) by frame
        if iFrame.size.width > image.size.width &&
            iFrame.size.height > image.size.height {
            let dx = (iFrame.size.width - image.size.width)/2.0
            let dy = (iFrame.size.height - image.size.height)/2.0
            return iFrame.insetBy(dx: dx, dy: dy)
        }
        
        // When there are vertical bars
        if iFrame.size.aspectRatio < image.size.aspectRatio {
            let imageViewHeight = iFrame.size.height
            let actualImageHeight = iFrame.size.width * 1/image.size.aspectRatio
            let dy = (imageViewHeight - actualImageHeight)/2.0
            return iFrame.insetBy(dx: 0, dy: dy)
        }
        
        // When there are horizontal bars
        let imageViewWidth = iFrame.size.width
        let actualImageWidth = iFrame.size.height * image.size.aspectRatio
        let dx = (imageViewWidth - actualImageWidth)/2.0
        return iFrame.insetBy(dx: dx, dy: 0)
    }
}
