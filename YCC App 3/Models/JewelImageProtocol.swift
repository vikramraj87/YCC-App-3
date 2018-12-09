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
    
    // Required to delete the original image after successful import
    var originalURL: URL { get }
    var editedURL: URL? { get set }
    
    var thumbnail: CGImage? { get set }
    
    var selectedTextObservations: [VNTextObservation]? { get set }
}

class JewelImage: JewelImageProtocol {
    var state: JewelImageState = .notReviewed
    
    let originalURL: URL
    var editedURL: URL?
    
    // To hold the thumbnail of original image
    var thumbnail: CGImage?
    
    var selectedTextObservations: [VNTextObservation]? {
        didSet {
            editedURL = nil
        }
    }
    
    init(originalURL: URL) {
        self.originalURL = originalURL
    }
}
