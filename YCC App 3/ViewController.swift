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
//    // MARK:- Outlets
//    @IBOutlet weak var imageView: NSImageView!
//    @IBOutlet weak var annotationView: AnnotationView!
//    
//    var textDetector = ImageTextDetector.shared
    
    lazy var jewelImportWindowController: NSWindowController = {
        let storyBoard = NSStoryboard(name: .jewelImport, bundle: nil)
        let controller = storyBoard.instantiateInitialController()
        return controller as! NSWindowController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        annotationView.imageView = imageView
//        annotationView.delegate = self
//
//        textDetector.delegate = self
    }

//    @IBAction func detectText(_ sender: Any) {
//        guard let image = imageView.image else {
//            print("No image loaded to detect text.")
//            return
//        }
//
//        textDetector.detectText(in: image)
//    }
    @IBAction func importJewelImages(_ sender: Any) {
        guard let jewelImportWindow = jewelImportWindowController.window else {
            print("Cannot load window")
            return
        }
        
        if jewelImportWindow.isVisible {
            jewelImportWindowController.showWindow(self)
            return
        }
        
        guard let window = view.window else {
            print("No window to present open panel")
            return
        }
        
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        
        openPanel.beginSheetModal(for: window) { [weak self] response in
            guard response == NSApplication.ModalResponse.OK else { return }
            let selectedFolderURL = openPanel.urls[0]
            let contentVC = jewelImportWindow.contentViewController
            guard let jewelImportViewController = contentVC as? JewelImageImportViewController else {
                print("Incorrect view controller instance")
                return
            }
            jewelImportViewController.selectedFolderURL = selectedFolderURL
            guard let strongSelf = self else {
                print("Self not available in open panel closure")
                return
            }
            strongSelf.jewelImportWindowController.showWindow(self)
        }
    }
}
//
//extension ViewController: ImageTextDetectorDelegate {
//    func textDetected(_ observations: [VNTextObservation]) {
//        annotationView.textObservations = observations
//    }
//}
//
//extension ViewController: AnnotationViewDelegate {
//    func annotationViewObservationsDidChange(_ newObservations: [VNTextObservation]) {
//        print("Observations changed")
//        // Send the new observations to server
//        // Update the code removed view with the image received from server
//    }
//}
