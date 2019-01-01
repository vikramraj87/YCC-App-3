//
//  JewelCode.swift
//  YCC App 3
//
//  Created by Vikram Raj Gopinathan on 30/12/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Foundation

struct JewelCode {
    var originalCode: Int = 0
    var multiplier: Float = 0
    var profit: Float = 0
    
    var retailerCode: Int = 0
    
    let prefix: String = "Code"
    
    var generatedCode: Int {
        let dealerPrice: Float = Float(originalCode) * multiplier
        let retailPrice = dealerPrice + profit
        let rounded = ceil(retailPrice/10.0) * 10
        return Int(rounded/2.0)
    }
    
    var position: CodePosition = .topRight
    var color: CodeColor = .light
    
    var code: Int {
        return retailerCode > 0 ? retailerCode : generatedCode
    }
    
    var displayCode: String {
        return "\(prefix) \(code)"
    }
}
