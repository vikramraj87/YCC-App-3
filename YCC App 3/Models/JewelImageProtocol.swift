//
//  JewelImageProtocol.swift
//  YCC App 3
//
//  Created by Vikram Raj Gopinathan on 25/11/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Cocoa

// Possible states of jewel image
// 0. Image not reviewed yet
// 1. Import cancelled
// 2. Code Removal unsuccessful. Original Image only imported
// 3. Code Removal successful. Both images imported

enum JewelImageState {
    case notReviewed
    case importCancelled
    case codeRemovalUnsuccessful
    case codeRemovalSuccessful
}


protocol JewelImageProtocol {
    var state: JewelImageState { get set }
    
    // Required to delete the original image after successful import
    var originalURL: URL { get }
    var editedURL: URL { get }
    
    var thumbnail: CGImage? { get set }
}

class JewelImage: JewelImageProtocol {
    var state: JewelImageState = .notReviewed
    
    let originalURL: URL
    let editedURL: URL
    
    var thumbnail: CGImage?
    
    init(originalURL: URL) {
        self.originalURL = originalURL
        self.editedURL = originalURL
    }
}
