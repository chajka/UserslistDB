//
//  JSONizableAllUsersTests.swift
//  UserslistDBTests
//
//  Created by Я Чайка on 2019/05/08.
//  Copyright © 2019 Чайка. All rights reserved.
//

import XCTest

class JSONizableAllUsersTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test01_allocation() {
		let allusers: JSONizableAllUsers = JSONizableAllUsers()
		XCTAssertNotNil(allusers, "all users can not allocated")
    }

	func test02_loadJSON() {
		let home: String = NSHomeDirectory()
		let sampleJSONURL: URL = URL(fileURLWithPath: home + "Documents/userslist.json")
		do {
			let decoder: JSONDecoder = JSONDecoder()
			let data: Data = try Data(contentsOf: sampleJSONURL)
			let allUsers: JSONizableAllUsers = try decoder.decode(JSONizableAllUsers.self, from: data)
			XCTAssertNotNil(allUsers, "userslist decoce from json userslist failed")
			if let isAnonymous: Bool = allUsers.isAnnonymousUser(identifierOf: "6347612") {
				XCTAssertFalse(isAnonymous, "user id 6347612 is seems to anonyous")
			} else {
				XCTAssertNotNil(allUsers.isAnnonymousUser(identifierOf: "6347612"), "user id 6347612 is not entried")
			}
			
		} catch let error {
			print(error.localizedDescription)
			XCTAssert(true, "exception catched")
		}
	}

	func test03_readJSONContents() {
		let home: String = NSHomeDirectory()
		let sampleJSONURL: URL = URL(fileURLWithPath: home + "Documents/userslist.json")
		do {
			let decoder: JSONDecoder = JSONDecoder()
			let data: Data = try Data(contentsOf: sampleJSONURL)
			let allUsers: JSONizableAllUsers = try decoder.decode(JSONizableAllUsers.self, from: data)
			XCTAssertNotNil(allUsers, "userslist decoce from json userslist failed")
			let users: JSONizableUsers = allUsers.users(forOwner: "6347612")
			XCTAssertNotNil(users, "users for owner 6347612 get failed")
			let user: JSONizableUser? = users.user(identifier: "6347612")
			XCTAssertNotNil(user, "user 6347612’s information gat failed")
		} catch let error {
			print(error.localizedDescription)
			XCTAssert(true, "exception catched")
		}
	}

	func test04_addUsers() {
		let home: String = NSHomeDirectory()
		let sampleJSONURL: URL = URL(fileURLWithPath: home + "Documents/userslist.json")
		do {
			let decoder: JSONDecoder = JSONDecoder()
			let data: Data = try Data(contentsOf: sampleJSONURL)
			let allUsers: JSONizableAllUsers = try decoder.decode(JSONizableAllUsers.self, from: data)
			XCTAssertNotNil(allUsers, "userslist decoce from json userslist failed")
			var user: JSONizableUser = JSONizableUser("chajka")
			var users: JSONizableUsers = JSONizableUsers()
			users.addUser(identifier: "6347613", with: user)
			_ = allUsers.addUsers(forOwner: "6347613", to: users)
			let users1 = allUsers.users(forOwner: "6347613")
			XCTAssertEqual(users, users1, "users set is incorrect")
			user = JSONizableUser("Чайка")
			users = JSONizableUsers(anonymousComment: false, enableMoonitor: false)
			_ = allUsers.addUsers(forOwner: "6347612", to: users)
			let users2: JSONizableUsers = allUsers.users(forOwner: "6347612")
			XCTAssertEqual(users, users2, "users set incorrect")
		} catch let error {
			print(error.localizedDescription)
			XCTAssert(true, "exception catched")
		}
	}

//	func test05_encodeAndDecode() {
//		let allUsers: JSONizableAllUsers = JSONizableAllUsers()
//		var user: JSONizableUser = JSONizableUser("chajka")
//		var users: JSONizableUsers = JSONizableUsers()
//		users.addUser(identifier: "6347613", with: user)
//		_ = allUsers.addUsers(forOwner: "6347613", to: users)
//		user = JSONizableUser("Чайка")
//		users = JSONizableUsers(anonymousComment: false, enableMoonitor: false)
//		_ = allUsers.addUsers(forOwner: "6347612", to: users)
//		let encoder: JSONEncoder = JSONEncoder()
//		encoder.outputFormatting = JSONEncoder.OutputFormatting.prettyPrinted
//		let decoder: JSONDecoder = JSONDecoder()
//		do {
//			let data: Data = try encoder.encode(allUsers)
//			let allUsers2: JSONizableAllUsers = try decoder.decode(JSONizableAllUsers.self, from: data)
//			XCTAssertEqual(allUsers, allUsers2, "original instance and decode from data instance is not equal")
//		} catch let error {
//			print(error.localizedDescription)
//		}
//	}


    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
			let home: String = NSHomeDirectory()
			let sampleJSONURL: URL = URL(fileURLWithPath: home + "Documents/userslist.json")
			do {
				let decoder: JSONDecoder = JSONDecoder()
				let data: Data = try Data(contentsOf: sampleJSONURL)
				let allUsers: JSONizableAllUsers = try decoder.decode(JSONizableAllUsers.self, from: data)
			} catch let error {
				print(error.localizedDescription)
			}
       }
    }

}
