//
//  BCHTornadoTests.swift
//  BCHTornadoTests
//
//  Created by Wilson on 2018/7/21.
//  Copyright © 2018 hufubit. All rights reserved.
//

import XCTest
@testable import BCHTornado
import BigInt

class BCHTornadoTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let numberFormatter = BTCNumberFormatter(bitcoinUnit: .BTC)
        print(numberFormatter?.amount(from: "0.02"))
        let amount = BigUInt(numberFormatter!.amount(from: "0.02"))
        XCTAssertEqual(amount, BigUInt(2000000))
        let averageValue = amount.quotientAndRemainder(dividingBy: BigUInt(3))
        print(averageValue)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
