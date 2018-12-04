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
    
    let imageLoaderQueue = DispatchQueue(label: "ImageLoaderQueue")
    
    
    let codeRemovalService = CodeRemovalService(host: "127.0.0.1", port: 5000)
    
    var cache: [URL: NSImage] = [:]
    var textDetector = ImageTextDetector()
    
    var jewelImage: JewelImageProtocol?
    
    static let imageMaxDimension: CGFloat = 800.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        annotationView.imageView = originalImageView
        annotationView.delegate = self
        
        textDetector.delegate = self
        
        originalImageView.image = nil
        editedImageView.image = nil
    }
    
}

extension JewelImageDetailsViewController: JewelImageStripViewControllerDelegate {
    func didSelect(_ jewelImage: JewelImageProtocol) {
        self.jewelImage = jewelImage
        imageLoaderQueue.async { [weak self] in
            guard let strongSelf = self else {
                print("Not able to get hold of self")
                return
            }
            
            let originalImage = strongSelf.image(for: jewelImage.originalURL)
            let editedImage = strongSelf.image(for: jewelImage.editedURL)
            
            
            DispatchQueue.main.async {
                strongSelf.originalImageView.image = originalImage
                strongSelf.editedImageView.image = editedImage
                
                strongSelf.textDetector.detectText(in: originalImage)
            }
        }
        
        originalImageView.image = NSImage(contentsOf: jewelImage.originalURL)
        editedImageView.image = NSImage(contentsOf: jewelImage.editedURL)
    }
    
    func image(for url: URL) -> NSImage {
        if let image = cache[url] {
            return image
        }
        
        let cgImage = ImageDownSampler.downsample(imageAt: url, to: JewelImageDetailsViewController.imageMaxDimension)
        let nsImage = NSImage(cgImage: cgImage, size: .zero)
        cache[url] = nsImage
        return nsImage
    }
}

extension JewelImageDetailsViewController: ImageTextDetectorDelegate {
    func textDetected(_ observations: [VNTextObservation]) {
        annotationView.textObservations = observations
    }
}

extension JewelImageDetailsViewController: AnnotationViewDelegate {
    func annotationViewObservationsDidChange(_ newObservations: [VNTextObservation]) {
        guard let jewelImage = jewelImage else {
            print("No JewelImage object available.")
            return
        }
        
        codeRemovalService.remove(newObservations, from: jewelImage) {
            [weak self] url in
            guard let strongSelf = self else {
                return
            }
            guard let editedImageURL = url else {
                return
            }
            strongSelf.editedImageView.image = NSImage(contentsOf: editedImageURL)
        }
    }
}

