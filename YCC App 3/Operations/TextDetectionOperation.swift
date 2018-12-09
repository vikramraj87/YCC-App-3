//
//  TextDetectionOperation.swift
//  YCC App 3
//
//  Created by Vikram Raj Gopinathan on 07/12/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Cocoa
import Vision

protocol ImageProvider {
    var image: NSImage? { get }
}

class TextDetectionOperation: AsyncOperation {
    var image: NSImage?
    fileprivate var observations: [VNTextObservation]?
    
    override func main() {
        if self.isCancelled { return }
        state = .executing
        
        let resizedImage: NSImage?
        if let image = image {
            resizedImage = image
        } else {
            let imageProvider = dependencies
                .filter { $0 is ImageProvider }
                .first as? ImageProvider
            resizedImage = imageProvider?.image
        }
        
        guard let resizedImg = resizedImage else { return }
        
        if self.isCancelled { return }
        
        let detector = ImageTextDetector(image: resizedImg) { observations in
            if self.isCancelled { return }
            self.observations = observations
            self.state = .finished
        }
        detector.detectText()
    }
}

extension TextDetectionOperation: TextObservationsProvider {
    var textObservations: [VNTextObservation]? { return observations }
}
