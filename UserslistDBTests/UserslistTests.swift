//
//  UserslistTests.swift
//  UserslistDBTests
//
//  Created by Чайка on 2018/06/29.
//  Copyright © 2018 Чайка. All rights reserved.
//

import XCTest

class UserslistTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test01_allocation() {
		let db:Userslist = Userslist(jsonPath: "/Volumes/SharkWire/build/UserslistDB/UserslistDBTests/test.json", user_session:[user_session])
		XCTAssertNotNil(db, "db can not allocate")
    }

	func test02_func_identifier() {
		let db:Userslist = Userslist(jsonPath: "/Volumes/SharkWire/build/UserslistDB/UserslistDBTests/test.json", user_session:[user_session])
		XCTAssertNoThrow(try db.user(identifier: "6347612"), "known user 6347612 is not found")
		XCTAssertThrowsError(try db.user(identifier: "1234567"), "unknown user 1234567 found", { (error) in
			print(error)
		})
	}

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
