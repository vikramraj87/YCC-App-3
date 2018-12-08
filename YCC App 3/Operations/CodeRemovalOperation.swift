//
//  CodeRemovalOperation.swift
//  YCC App 3
//
//  Created by Vikram Raj Gopinathan on 04/12/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Cocoa
import Vision


protocol TextObservationsProvider {
    var textObservations: [VNTextObservation]? { get }
}

class CodeRemovalOperation: AsyncOperation {
    fileprivate var _editedImageURL: URL?
    
    fileprivate let service: CodeRemovalService
    fileprivate let originalImageURL: URL
    
    var textObservations: [VNTextObservation]?
    
    init(service: CodeRemovalService, imageURL: URL) {
        self.service = service
        self.originalImageURL = imageURL
        
        super.init()
    }
    
    override func main() {
        if self.isCancelled { return }
        
        state = .executing
        
        let observations: [VNTextObservation]?
        if let textObservations = textObservations {
            observations = textObservations
        } else {
            let textObservationsProvider = dependencies
                .filter { $0 is TextObservationsProvider }
                .first as? TextObservationsProvider
            observations = textObservationsProvider?.textObservations
        }
        
        guard let textObs = observations else { return }
        
        if self.isCancelled { return }
        
        service.remove(textObs, fromImageAt: originalImageURL) { editedURL in
            if self.isCancelled { return }
            self._editedImageURL = editedURL
            self.state = .finished
        }
    }
    
}
