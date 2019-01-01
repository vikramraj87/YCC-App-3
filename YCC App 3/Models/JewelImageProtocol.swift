//
//  JewelImageProtocol.swift
//  YCC App 3
//
//  Created by Vikram Raj Gopinathan on 25/11/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Cocoa
import Vision

protocol JewelImageProtocol {
    var state: JewelImageState { get set }
    var originalURL: URL { get }
    var codeRemovedURL: URL? { get set }
    var annotatedURL: URL? { get set }
    var thumbnail: CGImage? { get set }
    var selectedTextObservations: [VNTextObservation]? { get set }
    var code: JewelCode { get set }
}

class JewelImage: JewelImageProtocol {
    var state: JewelImageState = .notReviewed
    
    let originalURL: URL
    var codeRemovedURL: URL?
    var annotatedURL: URL?
    
    // To hold the thumbnail of original image
    var thumbnail: CGImage?
    
    var selectedTextObservations: [VNTextObservation]? {
        didSet {
            codeRemovedURL = nil
        }
    }
    
    var code: JewelCode
    
    init(originalURL: URL) {
        self.originalURL = originalURL
        self.code = JewelCode()
    }
}
