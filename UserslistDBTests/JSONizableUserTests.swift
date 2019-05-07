//
//  JSONizableUserTests.swift
//  DeuxCheVauxTests
//
//  Created by Я Чайка on 2019/05/07.
//  Copyright © 2019 Чайка. All rights reserved.
//

import XCTest

class JSONizableUserTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test01_Allocation() {
		let handle: String = "Чайка"
		let user: JSONizableUser = JSONizableUser(handle)
		XCTAssertNotNil(user, "user is not initialized")
		XCTAssertEqual(user.handle, handle, "handle is not equal")
		XCTAssertNotNil(user.lastMet, "lastMet is empty or nil")
		XCTAssertNil(user.known, "property known is not nil")
		XCTAssertNil(user.lock, "property lock is not nil")
		XCTAssertNil(user.color, "property color is not nil")
		XCTAssertNil(user.note, "property note is not nil")
    }

	func test02_setAndGet() {
		let handle: String = "Чайка"
		let lock: Bool = true
		let known: Bool = false
		let color: String = "#00808080"
		let voice: String = "yukkkuri"
		let note: String = "Bad User"
		let user: JSONizableUser = JSONizableUser(handle)
		XCTAssertNotNil(user, "user is not initialized")
		XCTAssertEqual(user.handle, handle, "handle is not equal")
		XCTAssertNotNil(user.lastMet, "lastMet is empty or nil")
		XCTAssertNil(user.known, "property known is not nil")
		XCTAssertNil(user.lock, "property lock is not nil")
		XCTAssertNil(user.color, "property color is not nil")
		XCTAssertNil(user.note, "property note is not nil")
		user.lock = lock
		XCTAssertEqual(user.lock, lock, "property lock is not equal")
		user.known = known
		XCTAssertEqual(user.known, known, "property lock is not equal")
		user.color = color
		XCTAssertEqual(user.color, color, "property lock is not equal")
		user.voice = voice
		XCTAssertEqual(user.voice, voice, "property lock is not equal")
		user.note = note
		XCTAssertEqual(user.note, note, "property lock is not equal")
	}

	func testt03__storeSomeUser() {
		let encoder: JSONEncoder = JSONEncoder()
		let decoder: JSONDecoder = JSONDecoder()

		do {
			let handle: String = "Чайка"
			let user: JSONizableUser = JSONizableUser(handle)
			XCTAssertEqual(user.handle, handle, "handle is not equal")
			let data: Data = try encoder.encode(user)
			let user2: JSONizableUser = try decoder.decode(JSONizableUser.self, from: data)
			XCTAssertEqual(user, user2, "restored object is not equal")
		} catch let error {
			print(error.localizedDescription)
			XCTAssert(true, "exceptioon throwed \(error.localizedDescription)")
		}
	}

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
