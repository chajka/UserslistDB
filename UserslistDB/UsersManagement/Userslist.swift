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
		case met = "lasstMet"
		case note = "note"
	}// end enum user
}// end enum JSONKey

extension JSONKey.toplevel: StringEnum { }
extension JSONKey.owner: StringEnum { }
extension JSONKey.user: StringEnum { }

private let ThumbnailAPIFormat: String = "https://secure-dcdn.cdn.nimg.jp/nicoaccount/usericon/%@/%@.jpg"
private let NoImageThumbnailURL: String = "https://secure-dcdn.cdn.nimg.jp/nicoaccount/usericon/defaults/blank.jpg"
private let NicknameAPIFormat: String = "http://seiga.nicovideo.jp/api/user/info?id="
private let NicknameNodeName: String = "nickname"
private let informationUserIdentifier: String = "900000000"
private let informationUserName: String = "Information"

public class Userslist: NSObject {
	let jsonDatabase: NSMutableDictionary
	let ownersDictionary: NSMutableDictionary
	let usersDictionary: NSMutableDictionary

	private let databasePath: String
	private var currentOwners: Dictionary<String, NicoLiveListeners>
	private var observers: Dictionary<String, NSObject>
	
	private let cookies: [HTTPCookie]

	private let session: URLSession = URLSession(configuration: URLSessionConfiguration.default)
	private var reqest: URLRequest

	private var noImageUserImage: NSImage?
	private var anonymousImage: NSImage?
	private var offificalUserImage: NSImage?
	private var cruiseUserImage: NSImage?

	public init (jsonPath: String, user_session: [HTTPCookie]) {
		currentOwners = Dictionary()
		observers = Dictionary()
		cookies = user_session
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
		reqest = URLRequest(url: URL(string: NicknameAPIFormat)!)
		reqest.allHTTPHeaderFields = HTTPCookie.requestHeaderFields(with: cookies)
	}// end init

	deinit {
		let _ = updateDatabaseFile()
	}// end deinit

	public func setDefaultThumbnails(defaultUser: NSImage, anonymousUser: NSImage, officialUser: NSImage, cruiseUser: NSImage) {
		noImageUserImage = defaultUser
		anonymousImage = anonymousUser
		offificalUserImage = officialUser
		cruiseUserImage = cruiseUser
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

	public func start (owner: String, speechDefault: Bool, commentDefault: Bool, observer: NSObject? = nil) -> (speech: Bool, comment: Bool) {
		let ownerInfo: NSMutableDictionary = ownersDictionary[owner] as? NSMutableDictionary ?? NSMutableDictionary()
		let speech:Bool = ownerInfo[JSONKey.owner.speech] as? Bool ?? speechDefault
		let comment:Bool = ownerInfo[JSONKey.owner.anonymous] as? Bool ?? commentDefault
		let listenersForOwner: NSMutableDictionary = ownerInfo[JSONKey.owner.listeners] as? NSMutableDictionary ?? NSMutableDictionary()
		let listeners: NicoLiveListeners = NicoLiveListeners(listeners: listenersForOwner, allKnownUsers: usersDictionary)
		currentOwners[owner] = listeners
		if let obs: NSObject = observer { observers[owner] = obs }

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
		if observers[owner] != nil { observers.removeValue(forKey: owner) }
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
		let user: NicoLiveUser = try listeners.user(identifier: identifier)
		return user
	}// end func user

	public func user (identifier: String, premium: Int, anonymous: Bool, Lang: UserLanguage, forOwner owner: String, with error: UserslistError) throws -> NicoLiveUser {
		guard let listeners: NicoLiveListeners = currentOwners[owner] else { throw UserslistError.inactiveOwnner }
		var user: NicoLiveUser
		var nickname: String = ""
		if !anonymous { nickname = fetchNickname(identifier: identifier) }
		else if premium == 0x11 { nickname = fetchNickname(identifier: owner) }
		else if identifier == informationUserIdentifier { nickname = informationUserName }

		switch error {
		case .entriedUser:
			user = try listeners.activateUser(nickname: nickname, identifier: identifier, premium: premium, anonymous: anonymous, lang: Lang)
		case .inDatabaseUser:
			user = listeners.newUser(nickname: nickname, identifier: identifier, premium: premium, anonymous: anonymous, lang: Lang, met: Friendship.metOther)
		case .unknownUser: fallthrough
		default:
			let nickname: String = anonymous ? "" : fetchNickname(identifier: identifier)
			user = listeners.newUser(nickname: nickname, identifier: identifier, premium: premium, anonymous: anonymous, lang: Lang, met: Friendship.new)
		}// end switch case by exception name

		if !anonymous {
			let thumbURL: URL = thumbnailURL(identifier: identifier)
			if let observer = observers[owner] {
				user.addObserver(observer, forKeyPath: "thumbnail", options: [], context: nil)
			}// end if need observe thumbnail
			
			reqest.url = thumbURL
			let task: URLSessionDataTask = session.dataTask(with: reqest) { (dat, resp, err) in
				if let data = dat, let image: NSImage = NSImage(data: data) {
					user.thumbnail = image
				} else {
					user.thumbnail = self.noImageUserImage
				}// end if data is valid
			}// end closure when recieve data
			task.resume()
		} else {
			user.thumbnail = anonymousImage
		}// end !anonymous

		return user
	}// end func user
	
	public func userAnonymity (identifier: String) throws -> Bool {
		guard let anonimity: Bool = usersDictionary[identifier] as? Bool else { throw UserslistError.unknownUser }
		return anonimity
	}// end func user

	public func fetchNickname (identifier: String) -> String {
		guard let url = URL(string: NicknameAPIFormat + identifier) else { return "" }
		var fetchData: Bool = false
		var nickname: String = String()
		reqest.url = url
		let task:URLSessionDataTask = session.dataTask(with: reqest) { (dat, req, err) in
			if let data:Data = dat {
				do {
					let resultXML: XMLDocument = try XMLDocument(data: data, options: XMLNode.Options.documentTidyXML)
					guard let userNode = resultXML.children?.first?.children?.first else { throw NSError(domain: "could not parse", code: 0, userInfo: nil)}
					for child: XMLNode in (userNode.children)! {
						if child.name == NicknameNodeName { nickname = child.stringValue ?? "No Nickname (Charleston)"}
					}// end foreach
				} catch {
					nickname = "No Nickname (Charleston)"
				}// end try - catch parse XML document
			}// end if data is there
			fetchData = true
		}// end closure for recieve data
		task.resume()

		while (!fetchData) { Thread.sleep(forTimeInterval: 0.001)}
		return nickname
	}// end func fetchNickname

	private func thumbnailURL(identifier: String) -> URL {
		let prefix: String = String(identifier.prefix(identifier.count - 4))
		let urlString: String = String(format: ThumbnailAPIFormat, prefix, identifier)
		let url: URL = URL(string: urlString) ?? URL(string: NoImageThumbnailURL)!

		return url
	}// end func thumbnailURL
}// end class Userslist
