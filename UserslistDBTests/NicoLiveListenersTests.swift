//
//  NicoLiveListenersTests.swift
//  UserslistDBTests
//
//  Created by Чайка on 2018/07/05.
//  Copyright © 2018 Чайка. All rights reserved.
//

import XCTest

class NicoLiveListenersTests: XCTestCase {
	var db: Userslist?
	var ownersDictionary: NSMutableDictionary?
	var usersDictionary: NSMutableDictionary?
	var userEntry: NSMutableDictionary?
	var listenes: NSMutableDictionary?

    override func setUp() {
        super.setUp()
		let fullpath:String = "/Volumes/SharkWire/build/UserslistDB/UserslistDBTests/test.json"
		db = Userslist(jsonPath: fullpath)
		ownersDictionary = db?.ownersDictionary
		usersDictionary = db?.usersDictionary
		let owner: NSMutableDictionary = ownersDictionary?.object(forKey: "6347612") as! NSMutableDictionary
		listenes = owner.object(forKey: JSONKey.owner.listeners.rawValue) as? NSMutableDictionary
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test01_allocation() {
		let nicoLiveListeners: NicoLiveListeners = NicoLiveListeners(owner: "6347612", for: listenes!, and: usersDictionary!, user_session: [user_session])
		XCTAssertNotNil(nicoLiveListeners, "nico live listeners can not initoalize")
    }

	func test02_check_and_activate_user() {
		let nicoLiveListeners: NicoLiveListeners = NicoLiveListeners(owner: "6347612", for: listenes!, and: usersDictionary!, user_session: [user_session])
		XCTAssertNotNil(nicoLiveListeners, "nico live listeners can not initoalize")
		var user: NicoLiveUser
		do {
			XCTAssertThrowsError(try nicoLiveListeners.user(identifier: "6347612"), "unactivate user id : 6347612 is is there") { (error) in
				print(error)
			}
			user = try nicoLiveListeners.activateUser(identifier: "6347612", premium: 3, anonymous: false, lang: .en)
			XCTAssertNotNil(user, "instance for id 6347612 can not instatinate")
			let entry: NSMutableDictionary = listenes?.object(forKey: "6347612") as! NSMutableDictionary
			XCTAssertNotNil(entry.value(forKey: JSONKey.user.met.rawValue), "last met date not updated")
		} catch {
			print(error)
		}
	}

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
