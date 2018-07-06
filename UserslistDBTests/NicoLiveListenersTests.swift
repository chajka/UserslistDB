//
//  NicoLiveListenersTests.swift
//  UserslistDBTests
//
//  Created by Чайка on 2018/07/05.
//  Copyright © 2018 Чайка. All rights reserved.
//

import XCTest

class NicoLiveListenersTests: XCTestCase {
	var ownersDictionary:Dictionary<String, Any>?
	var usersDictionary:Dictionary<String, Bool>?
	var userEntry:Dictionary<String, String>?
	var listenes:Dictionary<String, Dictionary<String, String>>?

    override func setUp() {
        super.setUp()
		do {
			let fullpath:String = "/Volumes/SharkWire/build/UserslistDB/UserslistDBTests/test.json"
			let data:NSData = try NSData(contentsOfFile: fullpath)
			let jsonObj:[String: [String: Any]] = try JSONSerialization.jsonObject(with: data as Data, options: [JSONSerialization.ReadingOptions.mutableContainers, JSONSerialization.ReadingOptions.mutableLeaves]) as! [String : [String : Any]]
			ownersDictionary = jsonObj["owners"] as! [String : [String : Any]]
			usersDictionary = jsonObj["users"] as? [String : Bool]
			let owner:Dictionary<String, Any> = ownersDictionary!["6347612"]! as! Dictionary<String, Any>
			listenes = owner["listener"] as? Dictionary<String, Dictionary<String, String>>
			userEntry = listenes!["6347612"]!
		} catch {
			print(error)
		}// end try - catch open data and parse json to dictionary
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test01_allocation() {
		let nicloLiveListeners:NicoLiveListeners = NicoLiveListeners(listeners: listenes!, allKnownUsers: usersDictionary!)
		XCTAssertNotNil(nicloLiveListeners, "nico live listeners can not initoalize")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
