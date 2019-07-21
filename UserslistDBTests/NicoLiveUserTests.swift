//
//  NicoLiveUserTests.swift
//  UserslistDBTests
//
//  Created by Чайка on 2018/07/01.
//  Copyright © 2018 Чайка. All rights reserved.
//

import XCTest
import DeuxCheVaux

class NicoLiveUserTests: XCTestCase {
	var db: Userslist!
	let cookie: HTTPCookie? = HTTPCookie(properties: [HTTPCookiePropertyKey.domain: "nicovideo.jp", HTTPCookiePropertyKey.path: "/", HTTPCookiePropertyKey.name: "user_session", HTTPCookiePropertyKey.value: "user_session_6347612_afba1d09a6a664158fa87e6290a6aa3fbeb92edc02d4960a7e35ec6e1c6945f2"] )

    override func setUp() {
        super.setUp()
		let DocumentFolderPath: String = "/Users/chajka/Documents"
		db = Userslist(databaseFolderPath: DocumentFolderPath)
		let image: NSImage = NSImage()
		db.setDefaultThumbnails(defaultUser: image, anonymousUser: image, officialUser: image, cruiseUser: image)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test01_allocation_from_entry() {
		let usr: JSONizableUser = JSONizableUser("Чайка")
		let user: NicoLiveUser = NicoLiveUser(user: usr, identifier: "6347612", nickname: usr.handle, premium: 0b01, anonymous: false, lang: UserLanguage.en)
		XCTAssertNotNil(user, "Single user can not initialize")
		XCTAssertNotNil(user.name.nickname, "user nickname can not correct")
		XCTAssertNotNil(user.name.nickname, "user handle can not correct")
		XCTAssertNotNil(user.name.nickname, "user id can not correct")
		XCTAssertEqual(user.isPremium, true, "user is premium but class is not")
		XCTAssertEqual(user.friendship, Friendship.metOther, "user friendship incorrect")
		XCTAssertEqual(user.language, UserLanguage.en, "user Language incorrect")
		XCTAssertFalse(user.lock, "user isn’t lock but instance is locked")
		XCTAssertNil(user.color, "user haven’t color but instance have color")
		XCTAssertNil(user.note, "user haven’t note but instance have note")
    }

	func test02_allocation_from_entr_to_more_informationy() {
		let usr: JSONizableUser = JSONizableUser("Чайка")
		usr.known = false
		let user: NicoLiveUser = NicoLiveUser(user: usr, identifier: "6347612", nickname: usr.handle, premium: 0b01, anonymous: false, lang: UserLanguage.en)
		XCTAssertEqual(user.friendship, Friendship.met, "user friendship incorrect")
	}

	func test02_allocation_from_argument() {
		let stateForOwner = db.start(owner: "6347612", cookies: [cookie!])
		XCTAssertTrue(stateForOwner.comment, "Anonymous comment is not true")
		XCTAssertFalse(stateForOwner.monitor, "enable monitor is not true")
		do {
			let user: NicoLiveUser = try db.activatteUser (identifier: "6347612", premium: 1, anonymous: false, Lang: UserLanguage.en, forOwner: "6347612")

			XCTAssertNotNil(user, "Single user can not initialize")
			XCTAssertNotNil(user.name.nickname, "user nickname can not correct")
			XCTAssertNotNil(user.name.nickname, "user handle can not correct")
			XCTAssertNotNil(user.name.nickname, "user id can not correct")
			XCTAssertEqual(user.isPremium, true, "user is premium but class is not")
			XCTAssertEqual(user.friendship, Friendship.met, "user friendship incorrect")
			XCTAssertEqual(user.language, UserLanguage.en, "user Language incorrect")
			XCTAssertFalse(user.lock, "user isn’t lock but instance is locked")
			XCTAssertNil(user.color, "user haven’t color but instance have color")
			XCTAssertNil(user.note, "user haven’t note but instance have note")
		} catch let error {
			print(error.localizedDescription)
		}
	}

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
