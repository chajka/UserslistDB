//
//  Userslist.swift
//  UserslistDB
//
//  Created by Чайка on 2018/06/29.
//  Copyright © 2018 Чайка. All rights reserved.
//

import Cocoa

public enum UserslistError:Error {
	case unknownUser(String)
}

class Userslist: NSObject {
	private let ownersDictionary:[String: [String: Any]]
	private let usersDictionary:[String: Bool]
	private let cookies:[HTTPCookie]
	
	init(jsonPath:String, user_session:[HTTPCookie]) {
		cookies = user_session
		let fullpath:String = jsonPath.starts(with: "~") ? (jsonPath as NSString).expandingTildeInPath : jsonPath
		let fm = FileManager.default
		if !fm.fileExists(atPath: fullpath) {
			let defaultJasonPath:String = Bundle.main.path(forResource: "Userslist", ofType: "json")!
			do {
				try fm.moveItem(atPath: defaultJasonPath, toPath: fullpath)
			} catch let err {
				print(err)
			}// end try - catch move item
		}// end if not exist Userslist.json
		do {
			let data:NSData = try NSData(contentsOfFile: fullpath)
			let jsonObj:[String: [String: Any]] = try JSONSerialization.jsonObject(with: data as Data, options: [JSONSerialization.ReadingOptions.mutableContainers, JSONSerialization.ReadingOptions.mutableLeaves]) as! [String : [String : Any]]
			ownersDictionary = jsonObj["owners"] as! [String : [String : Any]]
			usersDictionary = jsonObj["users"] as! [String : Bool]
		} catch {
			print(error)
			ownersDictionary = Dictionary()
			usersDictionary = Dictionary()
		}// end try - catch open data and parse json to dictionary
	}// end init

	func user(identifier:String) throws -> Bool {
		let user:Bool? = usersDictionary[identifier]
		if let premium:Bool = user {
			return premium
		}// end if userid is entry in users
		throw UserslistError.unknownUser(identifier)
	}// end func user

}// end class Userslist
