//
//  JewelImageStripViewController.swift
//  YCC App 3
//
//  Created by Vikram Raj Gopinathan on 28/11/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Cocoa
import ImageIO

protocol JewelImageStripViewControllerDelegate: class {
    func didSelect(_ jewelImage: JewelImageProtocol)
}

// Preferences to be created
// 1. Layer Contents -> Aspect Vs AspectFill

class JewelImageStripViewController: NSViewController {
    var jewelImages: [JewelImageProtocol] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    weak var delegate: JewelImageStripViewControllerDelegate?
    
    @IBOutlet var collectionView: NSCollectionView!
    
    // Avoiding thread explosion when doing async work with serial queue
    let loadDecodeQueue = DispatchQueue(label: "LoadDecodeQueue")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        configureCollectionView(collectionView)
    }
    
    fileprivate func configureCollectionView(_ collectionView: NSCollectionView) {
        // Register the collectionview item
        let item = NSNib(nibNamed: .imageStripViewItem, bundle: nil)
        collectionView.register(item, forItemWithIdentifier: .imageStripItem)
        
        collectionView.wantsLayer = true
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.allowsEmptySelection = false
        collectionView.allowsMultipleSelection = false
        
        let layout = NSCollectionViewGridLayout()
        layout.margins = NSEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        layout.minimumItemSize = NSSize(width: 180, height: 240)
        layout.maximumNumberOfColumns = 1
        layout.minimumLineSpacing = 10.0
        
        collectionView.collectionViewLayout = layout
    }
}

extension JewelImageStripViewController: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return jewelImages.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: .imageStripItem, for: indexPath)
        
        guard let imageStripItem = item as? JewelImageStripViewItem else {
            print("Cannot get correct instance")
            return item
        }
        
        var jewelImage = jewelImages[indexPath.item]
        
        if jewelImage.thumbnail != nil {
            imageStripItem.jewelImage = jewelImage
            return imageStripItem
        }
        
        // Creating serial queue reduces the amount of threads allotted
        // when scrolling through collection views
        loadDecodeQueue.async {
            let thumbnail = ImageDownSampler.downsample(imageAt: jewelImage.originalURL,
                                                        to: Constants.thumbnailSize)
            jewelImage.thumbnail = thumbnail.cgImage(forProposedRect: nil,
                                                     context: nil,
                                                     hints: nil)
            DispatchQueue.main.async {
                imageStripItem.jewelImage = jewelImage
            }
        }
        
        return imageStripItem
    }
}

extension JewelImageStripViewController: NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else {
            print("No item selected")
            return
        }
        
        let jewelImage = jewelImages[indexPath.item]
        
        delegate?.didSelect(jewelImage)
    }
}
