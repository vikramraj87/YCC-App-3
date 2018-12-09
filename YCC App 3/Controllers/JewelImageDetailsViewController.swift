//
//  JewelImageDetailsViewController.swift
//  YCC App 3
//
//  Created by Vikram Raj Gopinathan on 28/11/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Cocoa
import Vision

extension OperationQueue {
    static func serialQueue() -> OperationQueue {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }
}

class JewelImageDetailsViewController: NSViewController {
    @IBOutlet var originalImageView: NSImageView!
    @IBOutlet var editedImageView: NSImageView!
    @IBOutlet var annotationView: AnnotationView!
    
    let codeRemovalService = CodeRemovalService(host: "127.0.0.1", port: 5000)
    
    var jewelImage: JewelImageProtocol?
    
    let originalImageQueue: OperationQueue = .serialQueue()
    let editedImageQueue: OperationQueue = .serialQueue()
    
    static let imageMaxDimension: CGFloat = 800.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        annotationView.imageView = originalImageView
        annotationView.delegate = self
        
        originalImageView.image = nil
        editedImageView.image = nil
    }
    
}

extension JewelImageDetailsViewController: JewelImageStripViewControllerDelegate {
    func didSelect(_ jewelImage: JewelImageProtocol) {
        self.jewelImage = jewelImage
        annotationView.textObservations = []
        
        originalImageQueue.cancelAllOperations()
        editedImageQueue.cancelAllOperations()
        
        var originalOps: [Operation] = []
        var editedOps: [Operation] = []
        var mainOps: [Operation] = []
        
        let maxDimension = JewelImageDetailsViewController.imageMaxDimension
        
        // Resize the image at url to the specified max dimension
        let resizeOp = ImageResizeOperation(maxDimension: maxDimension)
        resizeOp.imageURL = jewelImage.originalURL
        
        // Display the original image
        let origDisplayOp = DisplayImageOperation(imageView: originalImageView)
        origDisplayOp.addDependency(resizeOp)
        
        originalOps = [resizeOp]
        mainOps = [origDisplayOp]
        
        let editedResizeOp = ImageResizeOperation(maxDimension: maxDimension)
        
        let redisplayOp = DisplayImageOperation(imageView: editedImageView!)
        redisplayOp.addDependency(editedResizeOp)
        
        mainOps.append(redisplayOp)
        editedOps.append(editedResizeOp)
        
        
        if let observations = jewelImage.selectedTextObservations {
            origDisplayOp.completionBlock = { [weak self] in
                // Setting observations before the image is set im
                // imageview gives wrong image frame
                // Hence set in a completion block of display operation
                DispatchQueue.main.async {
                    self?.annotationView.textObservations = observations
                }
            }
            
            if let editedURL = jewelImage.editedURL {
                editedResizeOp.imageURL = editedURL
            } else {
                let codeRemovalOp = CodeRemovalOperation(service: codeRemovalService,
                                                         imageURL: jewelImage.originalURL)
                codeRemovalOp.textObservations = observations
                codeRemovalOp.completionBlock = { [weak self] in
                    self?.jewelImage?.editedURL = codeRemovalOp.imageURL
                }

                editedResizeOp.addDependency(codeRemovalOp)
                
                editedOps.append(codeRemovalOp)
            }
        } else {
            // If no edited image url exists, load the original image as place holder
            let editedDisplayOp = DisplayImageOperation(imageView: editedImageView!)
            editedDisplayOp.addDependency(resizeOp)
            mainOps.append(editedDisplayOp)

            // Detect text
            let textDetectionOp = TextDetectionOperation()
            textDetectionOp.addDependency(resizeOp)
            textDetectionOp.completionBlock = { [weak self] in
                self?.jewelImage?.selectedTextObservations = textDetectionOp.textObservations
                DispatchQueue.main.async {
                    self?.annotationView.textObservations = textDetectionOp.textObservations ?? []
                }
            }

            // Remove code
            let codeRemovalOp = CodeRemovalOperation(service: codeRemovalService,
                                                     imageURL: jewelImage.originalURL)
            codeRemovalOp.addDependency(textDetectionOp)
            codeRemovalOp.completionBlock = { [weak self] in
                self?.jewelImage?.editedURL = codeRemovalOp.imageURL
            }

            editedResizeOp.addDependency(codeRemovalOp)

            editedOps.append(contentsOf: [textDetectionOp, codeRemovalOp])
        }
        
        OperationQueue.main.addOperations(mainOps, waitUntilFinished: false)
        editedImageQueue.addOperations(editedOps, waitUntilFinished: false)
        originalImageQueue.addOperations(originalOps, waitUntilFinished: false)
    }
}

extension JewelImageDetailsViewController: AnnotationViewDelegate {
    func annotationViewObservationsDidChange(_ newObservations: [VNTextObservation]) {
        guard var jewelImage = jewelImage else {
            print("No JewelImage object available.")
            return
        }
        
        editedImageQueue.cancelAllOperations()
        
        jewelImage.selectedTextObservations = newObservations
        
        let codeRemovalOp = CodeRemovalOperation(service: codeRemovalService,
                                                 imageURL: jewelImage.originalURL)
        codeRemovalOp.textObservations = newObservations
        codeRemovalOp.completionBlock = { [weak self] in
            self?.jewelImage?.editedURL = codeRemovalOp.imageURL
        }
        
        let maxDimension = JewelImageDetailsViewController.imageMaxDimension
        let editedResizeOp = ImageResizeOperation(maxDimension: maxDimension)
        editedResizeOp.addDependency(codeRemovalOp)
        
        let redisplayOp = DisplayImageOperation(imageView: editedImageView!)
        redisplayOp.addDependency(editedResizeOp)
        
        OperationQueue.main.addOperation(redisplayOp)
        editedImageQueue.addOperations([codeRemovalOp, editedResizeOp],
                                       waitUntilFinished: false)
    }
}

