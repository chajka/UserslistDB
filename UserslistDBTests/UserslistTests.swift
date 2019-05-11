//
//  UserslistTests.swift
//  UserslistDBTests
//
//  Created by Чайка on 2018/06/29.
//  Copyright © 2018 Чайка. All rights reserved.
//

import XCTest

let testID: String = "6347612"
let testDBPath: String = "/Volumes/SharkWire/build/UserslistDB/UserslistDBTests/test.json"

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
		let db: Userslist = Userslist(jsonPath: testDBPath)
		XCTAssertNotNil(db, "db can not allocate")
    }

	func test02_func_identifier() {
		let db: Userslist = Userslist(jsonPath: testDBPath)
		XCTAssertNoThrow(try db.userAnonymity(identifier: testID), "known user 6347612 is not found")
		XCTAssertThrowsError(try db.userAnonymity(identifier: "1234567"), "unknown user 1234567 found", { (error) in
		XCTAssertNoThrow(try db.userOnymity(identifier: testID), "known user 6347612 is not found")
		XCTAssertThrowsError(try db.userOnymity(identifier: "1234567"), "unknown user 1234567 found", { (error) in
			print(error)
		})
	}

//	func test03_setup_for_owner() {
//		let db: Userslist = Userslist(jsonPath: testDBPath)
//		let img: NSImage = NSImage(size: NSMakeSize(64, 64))
//		db.setDefaultThumbnails(defaultUser: img, anonymousUser: img, officialUser: img, cruiseUser: img)
//		XCTAssertEqual(db.activeOwners().count, 0)
//		let result = db.start(owner: testID, speechDefault: false, commentDefault: false, cookies: [user_session])
//		XCTAssertFalse(result.speech, "Owner 6347612 enable speech")
//		XCTAssertTrue(result.comment, "Owner 6347612 disable annonymous comment")
//		XCTAssertEqual(db.activeOwners().count, 1)
//		db.end(owner: testID)
//		XCTAssertEqual(db.activeOwners().count, 0)
//		let success: Bool = db.updateDatabaseFile()
//		XCTAssertNoThrow(success, "update database json file failed")
//	}
//
//	func test04_activate_user() {
//		let db: Userslist = Userslist(jsonPath: testDBPath)
//		let img: NSImage = NSImage(size: NSMakeSize(64, 64))
//		db.setDefaultThumbnails(defaultUser: img, anonymousUser: img, officialUser: img, cruiseUser: img)
//		let _ = db.start(owner: testID, speechDefault: false, commentDefault: false, cookies: [user_session], observer: self)
//		var user: NicoLiveUser = NicoLiveUser(nickname: "abc", identifier: "cakd8ddkhdic7ed9dkahd", premium: 0, anonymous: true, lang: .ja, met: .new)
//		XCTAssertThrowsError(user = try db.user(identifier: testID, for: testID), "user 6347612 is not activate but no error") { (error) in
//			print(error)
//		}// end closure
//		do {
//			do {
//				user = try db.user(identifier: testID, for: testID)
//			} catch UserslistError.entriedUser {
//				XCTAssert(true, "user \(testID) reach here is correct")
//				user = try db.user(identifier: testID, premium: 1, anonymous: false, Lang: .en, forOwner: testID, with: .entriedUser)
//			} catch UserslistError.inDatabaseUser {
//				XCTAssert(false, "user \(testID) reach here is incorrect")
//				user = try db.user(identifier: testID, premium: 1, anonymous: false, Lang: .en, forOwner: testID, with: .inactiveOwnner)
//			} catch UserslistError.unknownUser {
//				XCTAssert(false, "user \(testID) reach here is incorrect")
//				user = try db.user(identifier: testID, premium: 1, anonymous: false, Lang: .en, forOwner: testID, with: .unknownUser)
//			} catch {
//				XCTAssert(false, "user \(testID) reach here is incorrect")
//			}
//		} catch UserslistError.inactiveOwnner {
//			XCTAssert(false, "owner not avilable in active owners")
//		} catch {
//			XCTAssert(false, "unknown error")
//		}
//		XCTAssertNotNil(user, "user \(testID) can not initialize")
//		XCTAssertNoThrow(user = try db.user(identifier: testID, for: testID), "activate user not found")
//	}
//
//	func test05_create_user() {
//		let db: Userslist = Userslist(jsonPath: testDBPath)
//		let img: NSImage = NSImage(size: NSMakeSize(64, 64))
//		db.setDefaultThumbnails(defaultUser: img, anonymousUser: img, officialUser: img, cruiseUser: img)
//		let _ = db.start(owner: testID, speechDefault: false, commentDefault: false, cookies: [user_session], observer: self)
//		var user:NicoLiveUser = NicoLiveUser(nickname: "abc", identifier: "cakd8ddkhdic7ed9dkahd", premium: 1, anonymous: true, lang: .ja, met: .new)
//		XCTAssertThrowsError(user = try db.user(identifier: "4582246", for: testID), "user 4582246 is not activate but no error") { (error) in
//			print(error)
//		}// end closure
//		do {
//			do {
//				user = try db.user(identifier: "4582246", for: testID)
//			} catch UserslistError.entriedUser {
//				XCTAssert(false, "user \("4582246") reach here is correct")
//				user = try db.user(identifier: "4582246", premium: 1, anonymous: false, Lang: .en, forOwner: testID, with: .entriedUser)
//			} catch UserslistError.inDatabaseUser {
//				XCTAssert(false, "user \("4582246") reach here is incorrect")
//				user = try db.user(identifier: "4582246", premium: 1, anonymous: false, Lang: .en, forOwner: testID, with: .inactiveOwnner)
//			} catch UserslistError.unknownUser {
//				XCTAssert(true, "user \("4582246") reach here is incorrect")
//				user = try db.user(identifier: "4582246", premium: 1, anonymous: false, Lang: .en, forOwner: testID, with: .unknownUser)
//			} catch {
//				XCTAssert(false, "user \("4582246") reach here is incorrect")
//			}
//		} catch UserslistError.inactiveOwnner {
//			XCTAssert(false, "owner not avilable in active owners")
//		} catch {
//			XCTAssert(false, "unknown error")
//		}
//		XCTAssertNotNil(user, "user \("4582246") can not initialize")
//		XCTAssertNoThrow(user = try db.user(identifier: "4582246", for: testID), "activate user not found")
//	}	
}
