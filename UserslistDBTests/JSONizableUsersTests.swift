//
//  JSONizableUsersTests.swift
//  UserslistDBTests
//
//  Created by Я Чайка on 2019/05/08.
//  Copyright © 2019 Чайка. All rights reserved.
//

import XCTest

class JSONizableUsersTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test01_ConvinienceAllocation() {
		let users: JSONizableUsers = JSONizableUsers()
		XCTAssertNotNil(users, "users allocation failed")
		XCTAssertTrue(users.anonymousComment, "default anonymous comment value is not false")
		XCTAssertFalse(users.monitor, "default enable monitor value is not false")
		let user: JSONizableUser? = users.user(identifier: "6347612")
		XCTAssertNotNil(user, "unkown user is entried")
    }

	func test02_NormalConstructor() {
		let users: JSONizableUsers = JSONizableUsers(anonymousComment: true, enableMoonitor: true)
		XCTAssertTrue(users.anonymousComment, "default anonymous comment value is not false")
		XCTAssertTrue(users.monitor, "default enable monitor value is not false")
		let user: JSONizableUser? = users.user(identifier: "6347612")
		XCTAssertNotNil(user, "unkown user is entried")
	}

	func test03_AppendUser() {
		let users: JSONizableUsers = JSONizableUsers()
		var user: JSONizableUser? = JSONizableUser("Чайка")
		users.addUser(identifier: "6347612", with: user!)
		user = users.user(identifier: "6347612")
		XCTAssertNotNil(user, "enttried user can nott get")
		XCTAssertTrue(users.anonymousComment, "default anonymous comment value is not false")
		XCTAssertFalse(users.monitor, "default enable monitor value is not false")
	}

	func test03_storeSomeUser() {
		let users: JSONizableUsers = JSONizableUsers()
		var user: JSONizableUser? = JSONizableUser("Чайка")
		users.addUser(identifier: "6347612", with: user!)
		user = users.user(identifier: "6347612")
		XCTAssertNotNil(user, "enttried user can nott get")
		XCTAssertTrue(users.anonymousComment, "default anonymous comment value is not false")
		XCTAssertFalse(users.monitor, "default enable monitor value is not false")
		user = JSONizableUser("chajka")
		users.addUser(identifier: "6347613", with: user!)
		user = users.user(identifier: "6347612")
		XCTAssertNotNil(user, "user of identhfier 6347612 entry lost")
		user = users.user(identifier: "6347613")
		XCTAssertNotNil(user, "user of identhfier 6347613 entry lost")
	}

	func tesst04_encodeAndDecode() {
		let users: JSONizableUsers = JSONizableUsers()
		var user: JSONizableUser? = JSONizableUser("Чайка")
		users.addUser(identifier: "6347612", with: user!)
		user = JSONizableUser("chajka")
		users.addUser(identifier: "6347613", with: user!)

		do {
			let encoder: JSONEncoder = JSONEncoder()
			let decoder: JSONDecoder = JSONDecoder()
			let data: Data = try encoder.encode(users)
			let user2: JSONizableUsers = try decoder.decode(JSONizableUsers.self, from: data)
			XCTAssertEqual(users, user2, "restored object is not equal")
		} catch let error {
			print(error.localizedDescription)
			XCTAssert(true, "exceptioon throwed \(error.localizedDescription)")
		}
	}

	func test05_checkUser() {
		let users: JSONizableUsers = JSONizableUsers()
		XCTAssertNotNil(users, "users allocation failed")
		var user: JSONizableUser = users.user(identifier: "6347612")
		XCTAssertNotNil(user, "user can not retrieved")
		XCTAssertEqual(user.handle, "6347612", "user handle is invalid")
		user = users.user(identifier: "6347612", userName: "Чайка")
		XCTAssertNotNil(user, "user can not retrieved")
		XCTAssertEqual(user.handle, "Чайка", "user handle is invalid")
	}

}
