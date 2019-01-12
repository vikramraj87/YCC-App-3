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
    
    var positionMenuItem: NSMenuItem!
    var colorMenuItem: NSMenuItem!
    
    var verticalPositionToolBarControl: NSSegmentedControl!
    var horizontalPositionToolBarControl: NSSegmentedControl!
    var colorToolBarControl: NSSegmentedControl!
    
    var currentSelectedCodePosition: CodePosition {
        let position: CodePosition
        switch (verticalPositionToolBarControl.selectedSegment, horizontalPositionToolBarControl.selectedSegment) {
        case (0, 0):
            position = .topLeft
        case (0, 1):
            position = .topRight
        case (1, 0):
            position = .bottomLeft
        default:
            position = .bottomRight
        }
        return position
    }
    
    var currentSelectCodeColor: CodeColor {
        return colorToolBarControl.selectedSegment == 0 ? .light : .dark
    }
    
    let exportQueue = OperationQueue.serialQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stripViewController = splitViewItems[0].viewController as? JewelImageStripViewController
        detailsViewController = splitViewItems[1].viewController as? JewelImageDetailsViewController
        
        stripViewController.delegate = detailsViewController
        detailsViewController.delegate = stripViewController
        
        getMenuReferences()
    }
    
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        getToolBarControlReferences()
        
        let imageURLs = FileManager.default.contents(of: selectedFolderURL,
                                                     withExtensions: Constants.allowedImageExtensions)
        
        stripViewController.jewelImages = imageURLs.map { imageURL in
            return JewelImage(originalURL: imageURL)
        }
    }
    
    private func getMenuReferences() {
        let app = NSApplication.shared
        guard let mainMenu = app.mainMenu else {
            return
        }
        
        let formatMenuItem = mainMenu.items.filter { $0.title == "Format" }.first!
        let formatMenu = formatMenuItem.submenu!
        
        positionMenuItem = formatMenu.items.filter { $0.title == "Position" }.first!
        colorMenuItem = formatMenu.items.filter { $0.title == "Text Color" }.first!
    }
    
    private func getToolBarControlReferences() {
        guard let toolbar = view.window?.toolbar else { return }
        
        let verticalPositionItem = toolbar.items.filter { $0.label == "Vertical Position" }.first!
        let horizontalPositionItem = toolbar.items.filter { $0.label == "Horizontal Position" }.first!
        let colorItem = toolbar.items.filter { $0.label == "Text Color" }.first!
        
        verticalPositionToolBarControl = (verticalPositionItem.view as! NSSegmentedControl)
        horizontalPositionToolBarControl = (horizontalPositionItem.view as! NSSegmentedControl)
        colorToolBarControl = (colorItem.view as! NSSegmentedControl)
    }
}

extension JewelImageImportViewController {
    @IBAction func changePositionMenuClicked(_ sender: NSMenuItem) {
        guard let positionMenu = sender.menu else { return }
        for item in positionMenu.items {
            item.state = item == sender ? .on : .off
        }
        
        let newPosition: CodePosition
        
        switch sender.title {
        case "Top Left":
            newPosition = .topLeft
        case "Top Right":
            newPosition = .topRight
        case "Bottom Left":
            newPosition = .bottomLeft
        default:
            newPosition = .bottomRight
        }
        
        setToolBar(for: newPosition)
    }
    
    @IBAction func changePositionToolBarClicked(_ sender: Any) {
        let newPosition: CodePosition
        switch (verticalPositionToolBarControl.selectedSegment, horizontalPositionToolBarControl.selectedSegment) {
        case (0, 0):
            newPosition = .topLeft
        case (0, 1):
            newPosition = .topRight
        case (1, 0):
            newPosition = .bottomLeft
        default:
            newPosition = .bottomRight
        }
        setMenu(for: newPosition)
    }
    
    @IBAction func changeTextColorMenuClicked(_ sender: NSMenuItem) {
        guard let colorMenu = sender.menu else { return }
        for item in colorMenu.items {
            item.state = item == sender ? .on : .off
        }
        
        let newColor: CodeColor
        switch  sender.title {
        case "Light":
            newColor = .light
        default:
            newColor = .dark
        }
        
        setToolBar(for: newColor)
    }
    
    @IBAction func changeColorToolBarClicked(_ sender: Any) {
        let newColor: CodeColor
        if colorToolBarControl.selectedSegment == 0 {
            newColor = .light
        } else {
            newColor = .dark
        }
        
        setMenu(for: newColor)
    }
    
    @IBAction func exportImages(_ sender: Any) {
        let jewelImages = stripViewController.jewelImages
        guard jewelImages.count > 0 else {
            print("There are no jewel images to export")
            return
        }
        
        let firstJewelImage = jewelImages.first!
        let currentFolder = firstJewelImage.originalURL.deletingPathExtension()
                                                       .deletingLastPathComponent()
        
        let editedFolder = currentFolder.appendingPathComponent("edited")
        let blackListedFolder = currentFolder.appendingPathComponent("blacklisted")
        
        let fm = FileManager.default
        
        do {
            try fm.createDirectory(at: editedFolder, withIntermediateDirectories: false, attributes: nil)
            try fm.createDirectory(at: blackListedFolder, withIntermediateDirectories: false, attributes: nil)
        } catch {
            print(error)
        }
        
        let ops = jewelImages.filter {
            return $0.state == .whiteListed || $0.state == .blackListed
        }.map {
            return ExportOperation(jewelImage: $0,
                                   editedFolder: editedFolder,
                                   blackListedFolder: blackListedFolder)
        }
        if let lastOp = ops.last {
            let refreshOp = BlockOperation { [weak self] in
                self?.stripViewController.collectionView.reloadData()
            }
            refreshOp.addDependency(lastOp)
            OperationQueue.main.addOperation(refreshOp)
        }
        exportQueue.addOperations(ops, waitUntilFinished: false)
    }
    
    private func setToolBar(for position: CodePosition) {
        verticalPositionToolBarControl.selectedSegment = position.isBottom ? 1 : 0
        horizontalPositionToolBarControl.selectedSegment = position.isLeft ? 0 : 1
    }
    
    private func setToolBar(for color: CodeColor) {
        colorToolBarControl.selectedSegment = color == .light ? 0 : 1
    }
    
    private func setMenu(for position: CodePosition) {
        let index: Int
        switch position {
        case .topLeft:
            index = 0
        case .topRight:
            index = 1
        case .bottomLeft:
            index = 2
        case .bottomRight:
            index = 3
        }
        
        let positionMenu = positionMenuItem.submenu!
        for item in positionMenu.items {
            item.state = .off
        }
        positionMenu.items[index].state = .on
    }
    
    private func setMenu(for color: CodeColor) {
        let colorMenu = colorMenuItem.submenu!
        for item in colorMenu.items {
            item.state = .off
        }
        let index = color == .light ? 0 : 1
        colorMenu.items[index].state = .on
    }
}
