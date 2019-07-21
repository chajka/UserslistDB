//
//  NicoLiveListenersTests.swift
//  UserslistDBTests
//
//  Created by Чайка on 2018/07/05.
//  Copyright © 2018 Чайка. All rights reserved.
//

import XCTest

public enum UserLanguage: String {
	case ja = "ja-jp"
	case zh = "zh-tw"
	case en = "en-us"

	static func ~= (lhs: UserLanguage, rhs: String) -> Bool {
		return lhs.rawValue == rhs ? true : false
	}// end func ~=

	static func == (lhs: UserLanguage, rhs: String) -> Bool {
		return lhs.rawValue == rhs ? true : false
	}// end func ==
}// end public enum UserLanguage

class NicoLiveListenersTests: XCTestCase {
	var allUser: JSONizableAllUsers!
	let cookie: HTTPCookie? = HTTPCookie(properties: [HTTPCookiePropertyKey.domain: "nicovideo.jp", HTTPCookiePropertyKey.path: "/", HTTPCookiePropertyKey.name: "user_session", HTTPCookiePropertyKey.value: "user_session_6347612_afba1d09a6a664158fa87e6290a6aa3fbeb92edc02d4960a7e35ec6e1c6945f2"] )

    override func setUp() {
        super.setUp()
		let fullpath: String = "/Users/chajka/Library/Application Support/Charleston/userslist.json"
		let uerslistURL: URL = URL(fileURLWithPath: fullpath)
		do {
			let data: Data = try Data(contentsOf: uerslistURL)
			let decoder: JSONDecoder = JSONDecoder()
			allUser = try decoder.decode(JSONizableAllUsers.self, from: data)
		} catch let error {
			print(error)
		}
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test01_allocation() {
		let listenersEntry: JSONizableUsers = allUser.users(forOwner: "6347612")
		let listeners: NicoLiveListeners = NicoLiveListeners(owner: "6347612", for: listenersEntry, user_session: [cookie!])
		XCTAssertNotNil(listeners, "nico live listeners can not initoalize")
		XCTAssertNotNil(listeners.owner, "owner is empty")
    }

	func test02_check_and_activate_user() {
		let listenersEntry: JSONizableUsers = allUser.users(forOwner: "6347612")
		let listeners: NicoLiveListeners = NicoLiveListeners(owner: "6347612", for: listenersEntry, user_session: [cookie!])
		XCTAssertNotNil(listeners, "nico live listeners can not initoalize")
		XCTAssertNotNil(listeners.owner, "owner is empty")
		XCTAssertThrowsError(try listeners.user(identifier: "6347612"), "inactive user 6347612 request did not thorw") { (err) in
			print(err.localizedDescription)}
		let user: NicoLiveUser = listeners.activateUser(identifier: "6347612", premium: 1, anonymous: false, lang: UserLanguage.ja)
		XCTAssertNotNil(user, "user of id 6347612 is not allocated")
		let user2 : NicoLiveUser = try! listeners.user(identifier: "6347612")
		XCTAssertEqual(user, user2, "both object is not same")
	}

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
