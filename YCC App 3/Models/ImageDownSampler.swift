//
//  ImageDownSampler.swift
//  YCC App 3
//
//  Created by Vikram Raj Gopinathan on 30/11/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Cocoa
import ImageIO

class ImageDownSampler {
    static func downsample(imageAt imageURL: URL, to maxDimension: CGFloat) -> NSImage {
        let imageSourceOptions = [
            kCGImageSourceShouldCache: false // Don't decode immediately
            ] as CFDictionary
        let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions)!

        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true, // When thumbnail is created, the image is decoded
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimension
            ] as CFDictionary

        let cgImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions)!
        return NSImage(cgImage: cgImage, size: .zero)
    }
}

