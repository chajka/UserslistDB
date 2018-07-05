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
		XCTAssertEqual(db.nickname(identifier: "6347612"), "Чайка", "user id 6347612 is not me")
	}

    func testPerformanceExample() {
		let db:Userslist = Userslist(jsonPath: "/Volumes/SharkWire/build/UserslistDB/UserslistDBTests/test.json", user_session:[user_session])
        self.measure {
			_ = db.nickname(identifier: "6347612")
        }
    }

}
