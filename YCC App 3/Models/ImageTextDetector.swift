//
//  ImageTextDetector.swift
//  YCC App 3
//
//  Created by Vikram Raj Gopinathan on 25/11/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Cocoa
import Vision

class ImageTextDetector {
    lazy var textDetectionRequest: VNDetectTextRectanglesRequest = {
        let request = VNDetectTextRectanglesRequest(completionHandler: textDetectionHandler)
        request.reportCharacterBoxes = true
        return request
    }()
    
    let image: NSImage
    let completionHandler: ([VNTextObservation]?) -> ()
    
    init(image: NSImage,
         completionHandler: @escaping ([VNTextObservation]?) -> ()) {
        self.image = image
        self.completionHandler = completionHandler
    }
    
    func detectText() {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            print("No CGImage backing for Image")
            return
        }
        
        let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try imageRequestHandler.perform([textDetectionRequest])
        } catch {
            print(error)
        }
    }
    
    fileprivate func textDetectionHandler(request: VNRequest, error: Error?) {
        guard let results = request.results else {
            print("No observations")
            self.completionHandler(nil)
            return
        }
        
        let observations = results.compactMap { $0 as? VNTextObservation }
        self.completionHandler(observations)
    }
}
