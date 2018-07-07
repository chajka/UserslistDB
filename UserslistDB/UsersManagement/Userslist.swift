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
	case entriedUser
	case inDatabaseUser
	case unknownUser
	case notInListeners
	case canNotUserActivate
}// end enum UsersListError

public enum JSONKey {
	enum toplevel:String {
		case owners = "owners"
		case users = "users"
	}// end enum toplevel
	enum owner:String {
		case listeners = "listener"
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

private let NicknameAPIFormat: String = "http://seiga.nicovideo.jp/api/user/info?id="
private let NicknameNodeName: String = "nickname"

class Userslist: NSObject {
	let jsonDatabase: NSMutableDictionary
	let ownersDictionary: NSMutableDictionary
	let usersDictionary: NSMutableDictionary

	private let databasePath: String
	private var currentOwners: Dictionary<String, NicoLiveListeners>
	private let cookies: [HTTPCookie]

	private let session: URLSession = URLSession(configuration: URLSessionConfiguration.default)
	private var reqest: URLRequest
	
	init (jsonPath: String, user_session: [HTTPCookie]) {
		currentOwners = Dictionary()
		cookies = user_session
		databasePath = jsonPath.starts(with: "~") ? (jsonPath as NSString).expandingTildeInPath : jsonPath
		let fm = FileManager.default
		if !fm.fileExists(atPath: databasePath) {
			let defaultJasonPath:String = Bundle.main.path(forResource: "Userslist", ofType: "json")!
			do {
				try fm.moveItem(atPath: defaultJasonPath, toPath: databasePath)
			} catch let err {
				print(err)
			}// end try - catch move item
		}// end if not exist Userslist.json
		do {
			let data:NSData = try NSData(contentsOfFile: databasePath)
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

	func updateDatabaseFile () -> Bool {
		do {
			let jsonData: Data = try JSONSerialization.data(withJSONObject: jsonDatabase, options: JSONSerialization.WritingOptions.prettyPrinted)
			try (jsonData as NSData).write(toFile: databasePath, options: NSData.WritingOptions.atomicWrite)
			return true
		} catch {
			print(error)
			return false
		}// end
	}// end updateDatabaseFile

	func start (owner: String, speechDefault: Bool, commentDefault: Bool) -> (speech: Bool, comment: Bool){
		let ownerInfo: NSMutableDictionary = ownersDictionary[owner] as? NSMutableDictionary ?? NSMutableDictionary()
		let speech:Bool = ownerInfo[JSONKey.owner.speech] as? Bool ?? speechDefault
		let comment:Bool = ownerInfo[JSONKey.owner.anonymous] as? Bool ?? commentDefault
		let listenersForOwner: NSMutableDictionary = ownerInfo[JSONKey.owner.listeners] as? NSMutableDictionary ?? NSMutableDictionary()
		let listeners: NicoLiveListeners = NicoLiveListeners(listeners: listenersForOwner, allKnownUsers: usersDictionary)
		currentOwners[owner] = listeners

		return (speech, comment)
	}// end func start

	func activeOwners () -> Dictionary<String, NicoLiveListeners>.Keys {
		return currentOwners.keys
	}// end func activeOwners

	func end (owner: String) -> Void {
		currentOwners.removeValue(forKey: owner)
	}// end func end

	func update (owner: String, speech:Bool) -> Void {
		guard let ownerInfo: NSMutableDictionary = ownersDictionary[owner] as? NSMutableDictionary else { return }
		ownerInfo[JSONKey.owner.speech] = speech
	}// end func update owner, speech

	func update (owner: String, comment:Bool) -> Void {
		guard let ownerInfo: NSMutableDictionary = ownersDictionary[owner] as? NSMutableDictionary else { return }
		ownerInfo[JSONKey.owner.anonymous] = comment
	}// end func update owner, speech
	
	func userAnonymity (identifier: String) throws -> Bool {
		guard let anonimity: Bool = usersDictionary[identifier] as? Bool else { throw UserslistError.unknownUser }
		return anonimity
	}// end func user

	public func nickname (identifier: String) -> String {
		if let url = URL(string: NicknameAPIFormat + identifier) {
			var fetchData: Bool = false
			var nickname: String = String()
			reqest.url = url
			let task:URLSessionDataTask = session.dataTask(with: reqest) { (dat, req, err) in
				if let data:Data = dat {
					do {
						let resultXML: XMLDocument = try XMLDocument(data: data, options: XMLNode.Options.documentTidyXML)
						let userNode = resultXML.children?.first?.children?.first
						for child: XMLNode in (userNode?.children)! {
							if child.name == NicknameNodeName { nickname = child.stringValue ?? "Not Found (Charleston)"}
						}// end foreach
					} catch {
						print ("get nickname xml parse error" )
					}// end try - catch parse XML document
				}// end if data is there
				fetchData = true
			}// end closure for recieve data
			task.resume()

			while (!fetchData) { Thread.sleep(forTimeInterval: 0.001)}
			return nickname
		}// end optional binding url
		return ""
	}// end func nickname
}// end class Userslist
