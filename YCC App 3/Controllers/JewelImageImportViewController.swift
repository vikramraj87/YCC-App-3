//
//  JewelImageImportViewController.swift
//  YCC App 3
//
//  Created by Vikram Raj Gopinathan on 28/11/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Cocoa

class JewelImageImportViewController: NSSplitViewController {
    var selectedFolderURL: URL!
    
    var stripViewController: JewelImageStripViewController!
    var detailsViewController: JewelImageDetailsViewController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stripViewController = splitViewItems[0].viewController as? JewelImageStripViewController
        detailsViewController = splitViewItems[1].viewController as? JewelImageDetailsViewController
        
        stripViewController.delegate = detailsViewController
    }
    
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        let imageURLs = FileManager.default.contents(of: selectedFolderURL,
                                                     withExtensions: Constants.allowedImageExtensions)
        
        stripViewController.jewelImages = imageURLs.map { imageURL in
            return JewelImage(originalURL: imageURL)
        }
    }
}
