//
//  NSSize+aspectRatio.swift
//  YCC App 3
//
//  Created by Vikram Raj Gopinathan on 24/11/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Cocoa

extension NSSize {
    var aspectRatio: CGFloat {
        return width/height
    }
}
