//
//  UserslistDBTests.swift
//  UserslistDBTests
//
//  Created by Чайка on 2018/06/29.
//  Copyright © 2018 Чайка. All rights reserved.
//

import XCTest
@testable import UserslistDB

private let user_session_value:String = "user_session_6347612_5bd6139de8350ccaada87bdd1cf9af9247b194d3819781c15e00bef5160c5023"
let user_session:HTTPCookie = HTTPCookie(properties: [HTTPCookiePropertyKey.domain: "nicovideo.jp", HTTPCookiePropertyKey.path: "/", HTTPCookiePropertyKey.name: "user_session", HTTPCookiePropertyKey.value: user_session_value])!

class UserslistDBTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
