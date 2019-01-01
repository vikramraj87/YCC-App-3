//
//  CodePosition.swift
//  YCC App 3
//
//  Created by Vikram Raj Gopinathan on 30/12/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Foundation

enum CodePosition {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}

extension CodePosition {
    var isBottom: Bool {
        return self == .bottomLeft || self == .bottomRight
    }
    
    var isLeft: Bool {
        return self == .bottomLeft || self == .topLeft
    }
}
