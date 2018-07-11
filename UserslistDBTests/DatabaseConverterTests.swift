//
//  DatabaseConverterTests.swift
//  UserslistDBTests
//
//  Created by Чайка on 2018/07/10.
//  Copyright © 2018 Чайка. All rights reserved.
//

import XCTest

class DatabaseConverterTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test01_debug() {
		do {
			let converter: DatabaseConverter = try DatabaseConverter(databasePath: "~/Library/Application Support/Charleston")
			let success = converter.parse()
			XCTAssertTrue(success, "parser parse fail")
		} catch {
			XCTFail("database can not read")
		}
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
