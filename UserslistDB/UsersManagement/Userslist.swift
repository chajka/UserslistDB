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
	case inactiveListener
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

public let DatabaseFileName: String = "userslist"
internal let DatabaseExtension: String = "json"

public enum JSONValue {
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
	
		// MARK: - Member variables
		// MARK: - Constructor/Destructor
	public init (databaseFolderPath jsonPath: String, databaseFileName: String = DatabaseFileName) {
		currentOwners = Dictionary()
		
		let databaseFolderURL: URL = URL(fileURLWithPath: (jsonPath.prefix(1) == "~") ? NSHomeDirectory() + String(jsonPath.suffix(jsonPath.count - 1)) : jsonPath, isDirectory: true)
		databaseURL = databaseFolderURL.appendingPathComponent(databaseFileName).appendingPathExtension(DatabaseExtension)
		let fm: FileManager = FileManager.default
		if !fm.fileExists(atPath: databaseURL.path) {
			let oldUserDatabaseURL: URL = databaseURL.deletingPathExtension().appendingPathExtension("xml")
			if fm.fileExists(atPath: oldUserDatabaseURL.path) {
				do {
					let converter: DatabaseConverter = try DatabaseConverter(databasePath: oldUserDatabaseURL.deletingLastPathComponent().path, databaseFile: oldUserDatabaseURL.lastPathComponent)
					let success = converter.parse()
					if success { _ = converter.writeJson() }
				} catch let error {
					print(error.localizedDescription)
				}// end do try - catch convert database
			} else {
				let defaultJasonPath:String = Bundle.main.path(forResource: "userslist", ofType: "json")!
				do {
					try fm.moveItem(atPath: defaultJasonPath, toPath: databaseURL.path)
				} catch let err {
					print(err)
				}// end try - catch move item
			}
		}// end if not exist Userslist.json
		do {
			let decoder: JSONDecoder = JSONDecoder()
			let data: Data = try Data(contentsOf: databaseURL)
			allUsers = try decoder.decode(JSONizableAllUsers.self, from: data)
		} catch let error {
			print(error)
			allUsers = JSONizableAllUsers()
		}// end try - catch open data and parse json to dictionary
		encoder.outputFormatting = JSONEncoder.OutputFormatting.prettyPrinted
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
	
	public func activeOwners () -> Array<String> {
		var result: Array<String> = Array()
		for key: String in currentOwners.keys {
			result.append(key)
		}// end foreach allkeys
		
		return result
	}// end func activeOwners
	
	public func start (owner: String, anonymousCommentDefault: Bool = true, monitorhDefault: Bool = false, cookies: [HTTPCookie], observer: NSObject? = nil) -> (comment: Bool, monitor: Bool) {
		let users: JSONizableUsers = allUsers.users(forOwner: owner, anonymousCommentDefault: anonymousCommentDefault, monitorhDefault: monitorhDefault)
		let listeners: NicoLiveListeners = NicoLiveListeners(owner: owner, for: users, user_session: cookies, observer: observer)
		
		listeners.setDefaultThumbnails(images: images)
		currentOwners[owner] = listeners
		
		return (users.anonymousComment, users.monitor)
	}// end func start
	
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
	
	public func user (identifier: String, premium: Int, anonymous: Bool, Lang: UserLanguage, forOwner owner: String, with error: UserslistError) throws -> NicoLiveUser {
		guard let listeners: NicoLiveListeners = currentOwners[owner] else { throw UserslistError.inactiveOwnner }
		var user: NicoLiveUser
		
		switch error {
		case .entriedUser:
			user = try listeners.activateUser(identifier: identifier, premium: premium, anonymous: anonymous, lang: Lang)
		case .inDatabaseUser:
			user = listeners.newUser(identifier: identifier, premium: premium, anonymous: anonymous, lang: Lang, met: Friendship.metOther)
		case .unknownUser: fallthrough
		default:
			user = listeners.newUser(identifier: identifier, premium: premium, anonymous: anonymous, lang: Lang, met: Friendship.new)
		}// end switch case by exception name
		
		return user
	}// end func user
	
	public func userAnonymity (identifier: String) throws -> Bool {
		guard let anonimity: Bool = usersDictionary[identifier] as? Bool else { throw UserslistError.unknownUser }
		return anonimity
	}// end func user
}// end class Userslist
