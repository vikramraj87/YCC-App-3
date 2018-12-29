//
//  NSImage+writeJPEG.swift
//  YCC App 3
//
//  Created by Vikram Raj Gopinathan on 13/12/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Cocoa

extension CodePosition {
    var isBottom: Bool {
        return self == .bottomLeft || self == .bottomRight
    }
    
    var isLeft: Bool {
        return self == .bottomLeft || self == .topLeft
    }
}

extension CodeColor {
    var nsColor: NSColor {
        return self == .light ? .white : .black
    }
}

extension NSImage {
    func writeJPEG(to url: URL) throws {
        let imageRepProps: [NSBitmapImageRep.PropertyKey: Any]
        imageRepProps = [.compressionFactor: 1.0]
        guard let imageData = self.tiffRepresentation,
            let imageRep = NSBitmapImageRep(data: imageData),
            let fileData = imageRep.representation(using: .jpeg, properties: imageRepProps) else {
                return
        }
        
        try fileData.write(to: url)
    }
}

extension NSImage {
    func drawText(_ text: String,
                  postion: CodePosition,
                  color: CodeColor,
                  fontSize: CGFloat = 36.0,
                  padding: CGFloat = 20.0) -> NSImage {
        let font = NSFont.boldSystemFont(ofSize: fontSize)
        let imageRect = CGRect(origin: .zero,
                               size: CGSize(width: size.width, height: size.height))
        
        // Configure text rect
        var textRect = CGRect.zero
        textRect.size = size
        
        if size.width > padding * 3 {
            textRect.origin.x = padding
            textRect.size.width = size.width - padding * 2.0
        }
        
        if size.height > padding * 3 {
            textRect.origin.y = padding
            textRect.size.height = postion.isBottom ? font.pointSize : size.height - padding * 2.0
        }
        
        // Configure Font attributes
        let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        textStyle.alignment = postion.isLeft ? .left : .right
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color.nsColor,
            .paragraphStyle: textStyle
        ]
        
        // Create a new image and add text
        let output = NSImage(size: size)
        let rep = NSBitmapImageRep(bitmapDataPlanes: nil,
                                   pixelsWide: Int(size.width),
                                   pixelsHigh: Int(size.height),
                                   bitsPerSample: 8,
                                   samplesPerPixel: 4,
                                   hasAlpha: true,
                                   isPlanar: false,
                                   colorSpaceName: .calibratedRGB,
                                   bytesPerRow: 0,
                                   bitsPerPixel: 0)!
        output.addRepresentation(rep)
        output.lockFocus()
        draw(in: imageRect)
        (text as NSString).draw(in: textRect, withAttributes: attributes)
        output.unlockFocus()
        return output
    }
}
