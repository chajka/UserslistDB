//
//  Userslist.swift
//  UserslistDB
//
//  Created by Чайка on 2018/06/29.
//  Copyright © 2018 Чайка. All rights reserved.
//

import Cocoa
import DeuxCheVaux

public enum UserslistError:Error {
	case unknownUser(String)
}

public enum JSONKey {
	enum toplevel:String {
		case owners = "owners"
		case users = "users"
	}// end enum toplevel
	enum owner:String {
		case speech = "speech"
		case anonymous = "anonymous"
	}// end enum owner
	enum user:String {
		case nickname = "nickname"
		case handle = "handle"
		case isPremium = "isPremium"
		case language = "Language"
		case friendship = "known"
		case lock = "lock"
		case color = "color"
		case met = "lasstMet"
		case note = "note"
	}// end enum user
}// end enum JSONKey

extension JSONKey.toplevel: StringEnum { }
extension JSONKey.owner: StringEnum { }
extension JSONKey.user: StringEnum { }

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
			ownersDictionary = jsonObj[JSONKey.toplevel.owners] as! [String : [String : Any]]
			usersDictionary = jsonObj[JSONKey.toplevel.users] as! [String : Bool]
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
