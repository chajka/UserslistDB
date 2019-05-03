//
//  Userslist.swift
//  UserslistDB
//
//  Created by Чайка on 2018/06/29.
//  Copyright © 2018 Чайка. All rights reserved.
//

import Cocoa
import DeuxCheVaux

public enum UserslistError: Error {
	case entriedUser
	case inDatabaseUser
	case unknownUser
	case notInListeners
	case canNotActivateUser
	case inactiveOwnner
}// end enum UsersListError

public enum JSONKey {
	enum toplevel: String {
		case owners = "owners"
		case users = "users"
	}// end enum toplevel
	enum owner: String {
		case listeners = "listener"
		case speech = "speech"
		case anonymous = "anonymous"
	}// end enum owner
	enum user: String {
		case nickname = "nickname"
		case handle = "handle"
		case isPremium = "isPremium"
		case language = "Language"
		case friendship = "known"
		case lock = "lock"
		case color = "color"
		case voice = "voice"
		case met = "lastMet"
		case note = "note"
	}// end enum user
}// end enum JSONKey

private enum JSONValue {
	enum BOOL: String {
		case yes = "yes"
		case no = "no"
	}// end enum bool
}// end enum JSONValue

extension JSONKey.toplevel: StringEnum { }
extension JSONKey.owner: StringEnum { }
extension JSONKey.user: StringEnum { }

public final class Userslist: NSObject {
	let jsonDatabase: NSMutableDictionary
	let ownersDictionary: NSMutableDictionary
	let usersDictionary: NSMutableDictionary
	
	private let databasePath: String
	private var currentOwners: Dictionary<String, NicoLiveListeners>
	private var images: Images!
	
	public init (jsonPath: String) {
		currentOwners = Dictionary()
		databasePath = jsonPath.starts(with: "~") ? (jsonPath as NSString).expandingTildeInPath : jsonPath
		let fm: FileManager = FileManager.default
		if !fm.fileExists(atPath: databasePath) {
			let defaultJasonPath:String = Bundle.main.path(forResource: "userslist", ofType: "json")!
			do {
				try fm.moveItem(atPath: defaultJasonPath, toPath: databasePath)
			} catch let err {
				print(err)
			}// end try - catch move item
		}// end if not exist Userslist.json
		do {
			let data: NSData = try NSData(contentsOfFile: databasePath)
			jsonDatabase = try JSONSerialization.jsonObject(with: data as Data, options: [JSONSerialization.ReadingOptions.mutableContainers, JSONSerialization.ReadingOptions.mutableLeaves]) as! NSMutableDictionary
			ownersDictionary = jsonDatabase[JSONKey.toplevel.owners] as? NSMutableDictionary ?? NSMutableDictionary()
			usersDictionary = jsonDatabase[JSONKey.toplevel.users] as? NSMutableDictionary ?? NSMutableDictionary()
		} catch {
			print(error)
			jsonDatabase = NSMutableDictionary()
			ownersDictionary = NSMutableDictionary()
			usersDictionary = NSMutableDictionary()
		}// end try - catch open data and parse json to dictionary
	}// end init
	
	deinit {
		let _ = updateDatabaseFile()
	}// end deinit
	
	public func setDefaultThumbnails(defaultUser: NSImage, anonymousUser: NSImage, officialUser: NSImage, cruiseUser: NSImage) {
		images = Images(noImageUser: defaultUser, anonymous: anonymousUser, offifical: officialUser, cruise: cruiseUser)
	}// end setDefaultThumbnails
	
	public func updateDatabaseFile () -> Bool {
		do {
			let jsonData: Data = try JSONSerialization.data(withJSONObject: jsonDatabase, options: JSONSerialization.WritingOptions.prettyPrinted)
			try (jsonData as NSData).write(toFile: databasePath, options: NSData.WritingOptions.atomicWrite)
			return true
		} catch {
			print(error)
			return false
		}// end
	}// end updateDatabaseFile
	
	public func start (owner: String, speechDefault: Bool, commentDefault: Bool, cookies: [HTTPCookie], observer: NSObject? = nil) -> (speech: Bool, comment: Bool) {
		let ownerInfo: NSMutableDictionary = ownersDictionary[owner] as? NSMutableDictionary ?? NSMutableDictionary()
		if ownerInfo.count == 0 {
			ownersDictionary[owner] = ownerInfo
			ownerInfo[JSONKey.owner.listeners] = NSMutableDictionary()
		}// end if new owner
		let speech:Bool = ownerInfo[JSONKey.owner.speech] as? Bool ?? speechDefault
		let comment:Bool = ownerInfo[JSONKey.owner.anonymous] as? Bool ?? commentDefault
		let listenersForOwner: NSMutableDictionary = ownerInfo[JSONKey.owner.listeners] as? NSMutableDictionary ?? NSMutableDictionary()
		let listeners: NicoLiveListeners = NicoLiveListeners(owner: owner, for: listenersForOwner, and: usersDictionary, user_session: cookies, observer: observer)
		listeners.setDefaultThumbnails(images: images)
		currentOwners[owner] = listeners
		
		return (speech, comment)
	}// end func start
	
	public func activeOwners () -> Array<String> {
		var result: Array<String> = Array()
		for key: String in currentOwners.keys {
			result.append(key)
		}// end foreach allkeys
		
		return result
	}// end func activeOwners
	
	public func end (owner: String) -> Void {
		currentOwners.removeValue(forKey: owner)
	}// end func end
	
	public func update (speech :Bool, forOwner owner: String) -> Void {
		guard let ownerInfo: NSMutableDictionary = ownersDictionary[owner] as? NSMutableDictionary else { return }
		ownerInfo[JSONKey.owner.speech] = speech
	}// end func update owner, speech
	
	public func update (anonymousComment: Bool, forOwner owner: String) -> Void {
		guard let ownerInfo: NSMutableDictionary = ownersDictionary[owner] as? NSMutableDictionary else { return }
		ownerInfo[JSONKey.owner.anonymous] = anonymousComment
	}// end func update owner, speech

	public func user (identifier: String, for owner: String) throws -> NicoLiveUser {
		guard let listeners: NicoLiveListeners = currentOwners[owner] else { throw UserslistError.inactiveOwnner }

		return try listeners.user(identifier: identifier)
	}// end user

	public func user (identifier: String, premium: Int, for owner: String) throws -> NicoLiveUser {
		guard let listeners: NicoLiveListeners = currentOwners[owner] else { throw UserslistError.inactiveOwnner }
		let user: NicoLiveUser = try listeners.user(identifier: identifier, premium: premium)
		return user
	}// end func user
	
	public func user (identifier: String, vip: Bool, premium: Int, anonymous: Bool, Lang: UserLanguage, forOwner owner: String, with error: UserslistError) throws -> NicoLiveUser {
		guard let listeners: NicoLiveListeners = currentOwners[owner] else { throw UserslistError.inactiveOwnner }
		var user: NicoLiveUser
		
		switch error {
		case .entriedUser:
			user = try listeners.activateUser(identifier: identifier, vip: vip, premium: premium, anonymous: anonymous, lang: Lang)
		case .inDatabaseUser:
			user = listeners.newUser(identifier: identifier, vip: vip, premium: premium, anonymous: anonymous, lang: Lang, met: Friendship.metOther)
		case .unknownUser: fallthrough
		default:
			user = listeners.newUser(identifier: identifier, vip: vip, premium: premium, anonymous: anonymous, lang: Lang, met: Friendship.new)
		}// end switch case by exception name
		
		return user
	}// end func user
	
	public func userAnonymity (identifier: String) throws -> Bool {
		guard let anonimity: Bool = usersDictionary[identifier] as? Bool else { throw UserslistError.unknownUser }
		return anonimity
	}// end func user
}// end class Userslist
