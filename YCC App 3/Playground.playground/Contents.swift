import UIKit

var str = "Hello, playground"

struct JewelCode {
    var originalCode: Int?
    var multiplier: Float?
    var profit: Float?
    
    var retailerCode: Int?
    
    let prefix: String = "Code"
    
    var generatedCode: Int? {
        guard let originalCode = originalCode,
            let multiplier = multiplier,
            let profit = profit else {
                return nil
        }
        
        let dealerPrice: Float = Float(originalCode) * multiplier
        let retailPrice = dealerPrice + profit
        let rounded = ceil(retailPrice/10.0) * 10
        return Int(rounded/2.0)
    }
//
//    var position: CodePosition = .topRight
//    var color: CodeColor = .light
    
    var displayCode: String? {
        if let retailerCode = retailerCode {
            return "\(prefix) \(retailerCode)"
        }
        if let generatedCode = generatedCode {
            return "\(prefix) \(generatedCode)"
        }
        return nil
    }
}

var code = JewelCode()

code.retailerCode = 200
code.displayCode

code.originalCode = 200
code.multiplier = 4.5
code.profit = 200
code.displayCode

code.originalCode = 200
code.multiplier = 4.5
code.profit = 200
code.retailerCode = 400
code.displayCode

