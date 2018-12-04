//
//  AnnotationView.swift
//  YCC App 3
//
//  Created by Vikram Raj Gopinathan on 23/11/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Cocoa
import Vision

protocol AnnotationViewDelegate: class {
    func annotationViewObservationsDidChange(_ newObservations: [VNTextObservation])
}

class AnnotationView: NSView {
    var textObservations: [VNTextObservation] = [] {
        didSet {
            boundingBoxes = []
            delegate?.annotationViewObservationsDidChange(textObservations)
            setNeedsDisplay(bounds)
        }
    }
    
    var boundingBoxes: [CGRect] = []
    var imageView: NSImageView? 
    weak var delegate: AnnotationViewDelegate?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configView()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        configView()
    }
    
    func configView() {
        wantsLayer = true
        
        let doubleClickRecognizer = NSClickGestureRecognizer()
        doubleClickRecognizer.numberOfClicksRequired = 2
        doubleClickRecognizer.target = self
        doubleClickRecognizer.action = #selector(doubleClicked(_:))
        self.addGestureRecognizer(doubleClickRecognizer)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        boundingBoxes = []
        
        guard let imageView = imageView else {
            print("Cannot annotate without imageView")
            return
        }
        
        guard let imageFrame = imageView.imageFrame else {
            print("Cannot get the frame of the image in imageView")
            return
        }
        
        annotateObservations(textObservations, inImageFrame: imageFrame)
    }
    
    
    fileprivate func annotateObservations(_ observations: [VNTextObservation], inImageFrame imageFrame: CGRect) {
        for observation in observations {
            let boundingBox = observation.boundingBoxScaled(to: imageFrame.size, shiftedBy: imageFrame.origin)
            boundingBoxes.append(boundingBox)
            let path = NSBezierPath(rect: boundingBox)
            NSColor.green.setStroke()
            path.stroke()
        }
    }
    
    func annotateImageFrame(_ imageFrame: CGRect) {
        let path = NSBezierPath(rect: imageFrame)
        NSColor.red.setStroke()
        path.stroke()
    }
    
    @objc
    func doubleClicked(_ gesture: NSClickGestureRecognizer) {
        let clickedPoint = gesture.location(in: self)
        
        for (index, boundingBox) in boundingBoxes.enumerated() {
            if boundingBox.contains(clickedPoint) {
                textObservations.remove(at: index)
                break
            }
        }
    }
}
