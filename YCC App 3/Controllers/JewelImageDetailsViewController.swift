//
//  JewelImageDetailsViewController.swift
//  YCC App 3
//
//  Created by Vikram Raj Gopinathan on 28/11/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Cocoa
import Vision

class JewelImageDetailsViewController: NSViewController {
    @IBOutlet var originalImageView: NSImageView!
    @IBOutlet var editedImageView: NSImageView!
    @IBOutlet var annotationView: AnnotationView!
    
    @IBOutlet var dealerCodeTextField: NSTextField!
    @IBOutlet var multiplierTextField: NSTextField!
    @IBOutlet var profitTextField: NSTextField!
    
    @IBOutlet var retailerCodeTextField: NSTextField!
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
    
    @IBAction func addCaption(_ sender: Any) {
        guard var jewelImage = jewelImage else { return }
        
        let retailerCode = retailerCodeTextField.integerValue
        
        if retailerCode != 0 {
            // Use this as final retailer code
            jewelImage.code.retailerCode = retailerCode
        } else {
            jewelImage.code.retailerCode = 0
            jewelImage.code.originalCode = dealerCodeTextField.integerValue
            jewelImage.code.multiplier = multiplierTextField.floatValue
            jewelImage.code.profit = profitTextField.floatValue
        }
        
        guard jewelImage.code.code > 0 else { return }
        guard let imageURL = jewelImage.codeRemovedURL,
            let image = NSImage(contentsOf: imageURL) else {
                return
        }
        
        // Annotate image
        let annotateOp = ImageAnnotateOperation(text: jewelImage.code.displayCode,
                                                color: jewelImage.code.color,
                                                position: jewelImage.code.position)
        annotateOp.inputImage = image
        
        // Save image to cache. Then save the url in JewelImage
        let saveToCacheOp = SaveImageOperation()
        saveToCacheOp.addDependency(annotateOp)
        saveToCacheOp.completionBlock = {
            jewelImage.annotatedURL = saveToCacheOp.imageURL
        }
        
        // Resize Saved Image
        let resizeOp = ImageResizeOperation(maxDimension: JewelImageDetailsViewController.imageMaxDimension)
        resizeOp.addDependency(saveToCacheOp)
        
        // Display
        let displayOp = DisplayImageOperation(imageView: editedImageView)
        displayOp.addDependency(resizeOp)
        
        OperationQueue.main.addOperation(displayOp)
        editedImageQueue.addOperations([resizeOp, saveToCacheOp, annotateOp], waitUntilFinished: false)
    }
    
    
}

extension JewelImageDetailsViewController: JewelImageStripViewControllerDelegate {
    func populateOriginalImageView(resizeOp: ImageResizeOperation) {
        let displayOp = DisplayImageOperation(imageView: originalImageView)
        displayOp.addDependency(resizeOp)
        OperationQueue.main.addOperation(displayOp)
    }
    
    func detectRemoveCodeAndDisplay(resizeOp: ImageResizeOperation) {
        guard var jewelImage = self.jewelImage else { return }
        
        // Display Original Image in Edited Image as place holder
        let placeHolderDisplayOp = DisplayImageOperation(imageView: editedImageView)
        placeHolderDisplayOp.addDependency(resizeOp)
        OperationQueue.main.addOperation(placeHolderDisplayOp)
        
        // Detect text from resizedImage
        let textDetectionOp = TextDetectionOperation()
        textDetectionOp.addDependency(resizeOp)
        textDetectionOp.completionBlock = { [weak self] in
            jewelImage.selectedTextObservations = textDetectionOp.textObservations
            DispatchQueue.main.async {
                self?.annotationView.textObservations = textDetectionOp.textObservations ?? []
            }
        }
        
        // Remove detected code
        let codeRemovalOp = CodeRemovalOperation(service: codeRemovalService,
                                                 imageURL: jewelImage.originalURL)
        codeRemovalOp.completionBlock = { [weak self] in
            self?.jewelImage?.codeRemovedURL = codeRemovalOp.imageURL
        }
        codeRemovalOp.addDependency(textDetectionOp)
        
        // Resize Code Removed Image
        let editedResizeOp = ImageResizeOperation(maxDimension: JewelImageDetailsViewController.imageMaxDimension)
        editedResizeOp.addDependency(codeRemovalOp)
        
        // Display resized code removed image
        let displayOp = DisplayImageOperation(imageView: editedImageView)
        displayOp.addDependency(editedResizeOp)
        OperationQueue.main.addOperation(displayOp)
        
        editedImageQueue.addOperations([
            editedResizeOp,
            codeRemovalOp,
            textDetectionOp
        ], waitUntilFinished: false)
    }
    
    func displayImageInEditedImageView(imageURL: URL) {
        // Resize the image
        let resizeOp = ImageResizeOperation(maxDimension: JewelImageDetailsViewController.imageMaxDimension)
        resizeOp.imageURL = imageURL
        
        // Display the Image
        let displayOp = DisplayImageOperation(imageView: editedImageView)
        displayOp.addDependency(resizeOp)
        
        OperationQueue.main.addOperation(displayOp)
        editedImageQueue.addOperation(resizeOp)
    }
    
    func displayObservationsAndEditedImage(resizeOp: ImageResizeOperation,
                                           observations: [VNTextObservation]) {
        guard var jewelImage = self.jewelImage else { return }
        
        // Display Original Image with Observations
        let origDisplayOp = DisplayImageOperation(imageView: originalImageView)
        origDisplayOp.addDependency(resizeOp)
        origDisplayOp.completionBlock = { [weak self] in
            DispatchQueue.main.async {
                self?.annotationView.textObservations = observations
            }
        }
        OperationQueue.main.addOperation(origDisplayOp)
        
        // If the code removed url exists, resize and display the image
        if let codeRemovedURL = jewelImage.codeRemovedURL {
            displayImageInEditedImageView(imageURL: codeRemovedURL)
            return
        }
        
        // If the observations exist but no code removed url
        removeCodeAndDisplay(observations: observations)
    }
    
    func removeCodeAndDisplay(observations: [VNTextObservation]) {
        guard var jewelImage = self.jewelImage else { return }
        
        // Remove code
        let codeRemovalOp = CodeRemovalOperation(service: codeRemovalService,
                                                 imageURL: jewelImage.originalURL)
        codeRemovalOp.textObservations = observations
        codeRemovalOp.completionBlock = {
            jewelImage.codeRemovedURL = codeRemovalOp.imageURL
        }
        
        // Resize
        let resizeOp = ImageResizeOperation(maxDimension: JewelImageDetailsViewController.imageMaxDimension)
        resizeOp.addDependency(codeRemovalOp)
        
        // Display
        let displayOp = DisplayImageOperation(imageView: editedImageView)
        displayOp.addDependency(resizeOp)
        
        OperationQueue.main.addOperation(displayOp)
        editedImageQueue.addOperations([resizeOp, codeRemovalOp],
                                       waitUntilFinished: false)
    }
    
    func populateTextFields(with code: JewelCode) {
        dealerCodeTextField.stringValue = code.originalCode == 0 ? "" : "\(code.originalCode)"
        multiplierTextField.stringValue = code.multiplier == 0 ? "" : "\(code.multiplier)"
        profitTextField.stringValue = code.profit == 0 ? "" : "\(code.profit)"
        
        retailerCodeTextField.stringValue = code.retailerCode == 0 ? "" : "\(code.retailerCode)"
    }
    
    func didSelect(_ jewelImage: JewelImageProtocol) {
        self.jewelImage = jewelImage
        annotationView.textObservations = []
        
        populateTextFields(with: jewelImage.code)
        
        originalImageQueue.cancelAllOperations()
        editedImageQueue.cancelAllOperations()
        
        let resizeOp = ImageResizeOperation(maxDimension: JewelImageDetailsViewController.imageMaxDimension)
        resizeOp.imageURL = jewelImage.originalURL
        
        populateOriginalImageView(resizeOp: resizeOp)
        
        defer {
            originalImageQueue.addOperation(resizeOp)
        }
        
        if let annotatedURL = jewelImage.annotatedURL {
            displayImageInEditedImageView(imageURL: annotatedURL)
            return
        }
        
        if let observations = jewelImage.selectedTextObservations {
            displayObservationsAndEditedImage(resizeOp: resizeOp,
                                              observations: observations)
            return
        }
        detectRemoveCodeAndDisplay(resizeOp: resizeOp)
        
    }
}

extension JewelImageDetailsViewController: AnnotationViewDelegate {
    func annotationViewObservationsDidChange(_ newObservations: [VNTextObservation]) {
        guard var jewelImage = jewelImage else { return }
        jewelImage.selectedTextObservations = newObservations
        
        editedImageQueue.cancelAllOperations()
        
        removeCodeAndDisplay(observations: newObservations)
    }
}

