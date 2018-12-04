//
//  VNTextObservationCollection+Encoded.swift
//  YCC App 3
//
//  Created by Vikram Raj Gopinathan on 02/12/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Foundation
import Vision

extension Collection where Element == VNTextObservation {
    var encoded: String {
        return reduce([]) {
            (accumulator: [VNRectangleObservation], current: VNTextObservation) -> [VNRectangleObservation] in
            return accumulator + (current.characterBoxes ?? [])
            }.map { (characterBox: VNRectangleObservation) -> String in
                return characterBox.boundingBox.encoded
            }.joined(separator: ";")
    }
}
