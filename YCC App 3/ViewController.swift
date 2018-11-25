//
//  ViewController.swift
//  YCC App 3
//
//  Created by Vikram Raj Gopinathan on 17/11/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Cocoa
import Vision




class ViewController: NSViewController {
    // MARK:- Outlets
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var annotationView: AnnotationView!
    
    var textDetector = ImageTextDetector()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        annotationView.imageView = imageView
        textDetector.delegate = self
    }

    @IBAction func detectText(_ sender: Any) {
        guard let image = imageView.image else {
            print("No image loaded to detect text.")
            return
        }
        
        textDetector.detectText(in: image)
    }
}

extension ViewController: ImageTextDetectorDelegate {
    func textDetected(_ observations: [VNTextObservation]) {
        annotationView.textObservations = observations
    }
}

