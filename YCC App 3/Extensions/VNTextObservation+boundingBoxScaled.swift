//
//  VNTextObservation+boundingBoxScaled.swift
//  YCC App 3
//
//  Created by Vikram Raj Gopinathan on 24/11/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Cocoa
import Vision

extension VNTextObservation {
    func boundingBoxScaled(to size: NSSize, shiftedBy delta: CGPoint = .zero) -> CGRect {
        return CGRect (
            x: delta.x + boundingBox.origin.x * size.width,
            y: delta.y + boundingBox.origin.y * size.height,
            width: boundingBox.width * size.width,
            height: boundingBox.height * size.height
        )
    }
}
