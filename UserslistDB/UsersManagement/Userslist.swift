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
		// MARK: - Properties
	public let officialUser: NicoLiveUser
	public let cruiseUser: NicoLiveUser
	public let guideUser: NicoLiveUser
		// MARK: - Member variables
	private let allUsers: JSONizableAllUsers
	private let encoder: JSONEncoder = JSONEncoder()

	private let databaseURL: URL
	private var currentOwners: Dictionary<String, NicoLiveListeners>

	private let officialEntry: JSONizableUser
	private let cruiseEntry: JSONizableUser

	private let queue: DispatchQueue = DispatchQueue(label: "tv.from.chajka.UserslistDatabase", qos: DispatchQoS.background)
	private var images: Images!

		// MARK: - Constructor/Destructor
	public init (databaseFolderPath jsonPath: String, databaseFileName: String = DatabaseFileName) {
		currentOwners = Dictionary()

		let databaseFolderURL: URL = URL(fileURLWithPath: (jsonPath.prefix(1) == "~") ? NSHomeDirectory() + String(jsonPath.suffix(jsonPath.count - 1)) : jsonPath, isDirectory: true)
		databaseURL = databaseFolderURL.appendingPathComponent(databaseFileName).appendingPathExtension(DatabaseExtension)
		let fm: FileManager = FileManager.default
		if !fm.fileExists(atPath: databaseURL.path) {
			let deuxCheVaux: DeuxCheVaux = DeuxCheVaux.shared
			deuxCheVaux.setFirstLaucn()
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
		officialEntry = JSONizableUser("Official", true, true)
		officialUser = NicoLiveUser(user: officialEntry, known: true, identifier: officialEntry.handle, nickname: officialEntry.handle, premium: 0b110, anonymous: false, lang: UserLanguage.ja)
		cruiseEntry = JSONizableUser("Cruise", true, true)
		cruiseUser = NicoLiveUser(user: cruiseEntry, known: true, identifier: cruiseEntry.handle, nickname: cruiseEntry.handle, premium: 0b10, anonymous: false, lang: UserLanguage.ja)
		super.init()
		cleanupOutdatedUser()
	}// end init

	deinit {
		let _ = updateDatabaseFile()
	}// end deinit

		// MARK: - Override
		// MARK: - Public methods
	public func setDefaultThumbnails(defaultUser: NSImage, anonymousUser: NSImage, officialUser: NSImage, cruiseUser: NSImage) {
		images = Images(noImageUser: defaultUser, anonymous: anonymousUser, official: officialUser, cruise: cruiseUser)
		self.officialUser.thumbnail = officialUser
		self.cruiseUser.thumbnail = cruiseUser
	}// end setDefaultThumbnails

	public func updateDatabaseFile () -> Bool {
		do {
			let data: Data = try encoder.encode(allUsers)
			try data.write(to: databaseURL, options: Data.WritingOptions.atomic)

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

	public func start (owner: String, anonymousCommentDefault: Bool = true, monitorDefault: Bool = false, fetcher informationFetcher: NicoInformationHandler, observer: NSObject? = nil) -> (comment: Bool, monitor: Bool) {
		let users: JSONizableUsers = allUsers.users(forOwner: owner, anonymousCommentDefault: anonymousCommentDefault, monitorDefault: monitorDefault)
		let listeners: NicoLiveListeners = NicoLiveListeners(owner: owner, for: users, fetcher: informationFetcher)

		listeners.setDefaultThumbnails(images: images)
		currentOwners[owner] = listeners

		return (users.anonymousComment, users.monitor)
	}// end func start

	public func end (owner: String) -> Void {
		guard let users: NicoLiveListeners = currentOwners[owner] else { return }
		users.finishProcess()
		currentOwners.removeValue(forKey: owner)
	}// end func end

	public func user (identifier: String, premium: Int, for owner: String) throws -> NicoLiveUser {
		if premium ^ 0b11 == 0 {
			if let listeners: NicoLiveListeners = currentOwners[owner] {
				return listeners.owner
			}// end optional binding check for argumented owner is in currentOwners
		}// end if premium is owner value

		guard let listeners: NicoLiveListeners = currentOwners[owner] else { throw UserslistError.inactiveOwnner }
		let user: NicoLiveUser = try listeners.user(identifier: identifier)

		return user
	}// end func user

	public func activateUser (identifier: String, premium: Int, anonymous: Bool, Lang: UserLanguage, forOwner owner: String, thumbnailHandler: @escaping ThumbNailCompletionHandler) throws -> NicoLiveUser {
		guard let users: NicoLiveListeners = currentOwners[owner] else { throw UserslistError.inactiveOwnner }
		allUsers.addUser(identifier: identifier, onymity: !anonymous)
		let user: NicoLiveUser = users.activateUser(identifier: identifier, premium: premium, anonymous: anonymous, lang: Lang, handler: thumbnailHandler)
		setUserOnymity(identifier: identifier, to: !anonymous)
		queue.async {
			_ = self.updateDatabaseFile()
		}// end background database file update

		return user
	}// end fuc activate user

	public func userOnymity (identifier: String) throws -> Bool {
		guard let onymity: Bool = allUsers.onymity(ofUserIdentifier: identifier) else { throw UserslistError.unknownUser }
		return onymity
	}// end func user

	public func setUserOnymity (identifier user: String, to onymity: Bool) {
		allUsers.addUser(identifier: user, onymity: onymity)
	}// end set user onymity

	public func set (commentAnonymity anonymity: Bool, toOwner owner: String) {
		guard let listeners: NicoLiveListeners = currentOwners[owner] else { return }
		listeners.set(commentAAnonymity: anonymity)
	}// end func set comment anonymity

	public func set (monitorState state: Bool, toOwner owner: String) {
		guard let listeners: NicoLiveListeners = currentOwners[owner] else { return }
		listeners.set(monitorState: state)
	}// end set enable monitor or not

		// MARK: - Internal methods
		// MARK: - Private methods
	private func cleanupOutdatedUser () {
		let queue: DispatchQueue = DispatchQueue(label: "tv.from.chajka.UserslistDB", qos: DispatchQoS.background, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit)
		queue.async { [weak self] in
			guard let weakSelf = self else { return }
			let calendar: Calendar = Calendar.current
			let component: DateComponents = DateComponents(hour: 9, minute: 0, weekday: 5)
			guard let lastThu: Date = calendar.nextDate(after: Date(), matching: component, matchingPolicy: Calendar.MatchingPolicy.nextTime, direction: .backward) else { return }

			let formatter:DateFormatter = DateFormatter()
			formatter.dateStyle = DateFormatter.Style.short
			formatter.timeStyle = DateFormatter.Style.short
			let cleanupBeforeDate: String = formatter.string(from: lastThu)

			weakSelf.allUsers.cleanupOutdatedUser(before: cleanupBeforeDate)
			_ = weakSelf.updateDatabaseFile()
		}// end queue async
	}// end cleanupOutdatedUser

		// MARK: - Delegates
}// end class Userslist
