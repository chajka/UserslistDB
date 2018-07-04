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
	var ownersDictionary:Dictionary<String, Any>?
	var usersDictionary:Dictionary<String, Any>?
	var userEntry:Dictionary<String, String>?

    override func setUp() {
        super.setUp()
		do {
			let fullpath:String = "/Volumes/SharkWire/build/UserslistDB/UserslistDBTests/test.json"
			let data:NSData = try NSData(contentsOfFile: fullpath)
			let jsonObj:[String: [String: Any]] = try JSONSerialization.jsonObject(with: data as Data, options: [JSONSerialization.ReadingOptions.mutableContainers, JSONSerialization.ReadingOptions.mutableLeaves]) as! [String : [String : Any]]
			ownersDictionary = jsonObj["owners"] as! [String : [String : Any]]
			usersDictionary = jsonObj["users"] as! [String : Bool]
			let owner:Dictionary<String, Any> = ownersDictionary!["6347612"]! as! Dictionary<String, Any>
			let listenes:Dictionary<String, Dictionary<String, String>> = owner["listener"]! as! Dictionary<String, Dictionary>
			userEntry = listenes["6347612"]!
		} catch {
			print(error)
		}// end try - catch open data and parse json to dictionary
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test01_allocation_from_entry() {
		let user:NicoLiveUser = NicoLiveUser(user: userEntry!, identifier: "6347612", anonymous: false, lang: UserLanguage.en)
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
    }

	func test02_allocation_from_argument() {
		let user:NicoLiveUser = NicoLiveUser(nickname: "chajka", identifier: "6347612", premium: true, anonymous: false, lang: UserLanguage.en, met: Friendship.met)
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
	}
	
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
