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

    func test01_convert() {
		do {
			let converter: DatabaseConverter = try DatabaseConverter(databasePath: "~/Library/Application Support/Charleston")
			let success = converter.parse()
			XCTAssertTrue(success, "parser parse fail")
			if success {
				let result: Bool = converter.writeJson()
				XCTAssertTrue(result, "write test jaon failed")
			}// end if
		} catch {
			XCTFail("database can not read")
		}
    }

	func test02_decode() {
		let usersListUFolderURL: URL = URL(fileURLWithPath: (NSHomeDirectory() + "/Library/Application Support/Charleston"), isDirectory: true)
		let usersListJSonURL: URL = usersListUFolderURL.appendingPathComponent("userslist").appendingPathExtension("json")
		let decoder: JSONDecoder = JSONDecoder()
		do {
			let data: Data = try Data(contentsOf: usersListJSonURL, options: Data.ReadingOptions.uncachedRead)
			let allUsers: JSONizableAllUsers = try decoder.decode(JSONizableAllUsers.self, from: data)
			XCTAssertNotNil(allUsers, "all user decode from json file is incorrect")
		} catch let error {
			XCTAssertNil(error, "\(error.localizedDescription)")
		}
	}

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
