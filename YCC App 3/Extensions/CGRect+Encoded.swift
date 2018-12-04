//
//  CGRect+Encoded.swift
//  YCC App 3
//
//  Created by Vikram Raj Gopinathan on 02/12/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Foundation

extension CGRect {
    var encoded: String {
        return "\(origin.x),\(origin.y),\(size.width),\(size.height)"
    }
}
