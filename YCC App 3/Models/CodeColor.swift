//
//  CodeColor.swift
//  YCC App 3
//
//  Created by Vikram Raj Gopinathan on 30/12/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Cocoa

enum CodeColor {
    case light
    case dark
}

extension CodeColor {
    var nsColor: NSColor {
        return self == .light ? .white : .black
    }
}
