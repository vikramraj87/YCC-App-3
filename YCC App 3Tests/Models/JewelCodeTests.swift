//
//  JewelCodeTests.swift
//  YCC App 3Tests
//
//  Created by Vikram Raj Gopinathan on 30/12/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import XCTest

class JewelCodeTests: XCTestCase {

//    override func setUp() {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }

//    func testExample() {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

    func testGeneratedCodeCalculation() {
        var code = JewelCode()
        code.originalCode = 300
        code.multiplier = 3.5
        code.profit = 250
        
        XCTAssertEqual("Code 650", code.displayCode)
    }
    
    func testRetailerCodeTakesOverGeneratedCode() {
        var code = JewelCode()
        code.originalCode = 300
        code.multiplier = 3.5
        code.profit = 250
        code.retailerCode = 400
        
        XCTAssertEqual("Code 400", code.displayCode)
    }
    
}
