//
//  JewelImageStripViewItem.swift
//  YCC App 3
//
//  Created by Vikram Raj Gopinathan on 28/11/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Cocoa

extension JewelImageState {
    var borderColor: CGColor {
        switch self {
        case .notReviewed:
            return NSColor.lightGray.cgColor
        case .blackListed:
            return NSColor.systemRed.cgColor
        case .whiteListed:
            return NSColor.systemGreen.cgColor
        case .exported:
            return NSColor.systemPurple.cgColor
        }
    }
}


class JewelImageStripViewItem: NSCollectionViewItem {
    // Constants to hold the colors for various states
    static let notReviewedColor = NSColor.lightGray.cgColor
//    static let codeRemovedColor = NSColor.systemGreen.cgColor
//    static let codeNotRemovedColor = NSColor.systemOrange.cgColor
//    static let notImportedColor = NSColor.systemRed.cgColor
//    static let exportedColor = NSColor.cyan.cgColor
    static let selectedColor = NSColor.selectedMenuItemColor.cgColor
    
    var jewelImage: JewelImageProtocol? {
        didSet {
            view.layer?.contents = jewelImage?.thumbnail
            view.layer?.borderColor = borderColor
        }
    }
    
    override var isSelected: Bool {
        didSet {
            view.layer?.borderColor = borderColor
        }
    }
    
    var borderColor: CGColor {
        if isSelected {
            return JewelImageStripViewItem.selectedColor
        }
        return unselectedBorderColor
    }
    
    var unselectedBorderColor: CGColor {

        guard let jewelImage = jewelImage else {
            return JewelImageStripViewItem.notReviewedColor
        }

        return jewelImage.state.borderColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        
        guard let viewLayer = view.layer else {
            return
        }
        configureViewLayer(viewLayer)
    }
    
    override func prepareForReuse() {
        isSelected = false
        jewelImage = nil
        
    }
    
    fileprivate func configureViewLayer(_ layer: CALayer) {
        layer.borderWidth = 4.0
        layer.cornerRadius = 0
        layer.masksToBounds = true
        layer.contentsGravity = .resizeAspectFill
    }
}
