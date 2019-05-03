//
//  NicoLiveListeners.swift
//  UserslistDB
//
//  Created by Чайка on 2018/07/05.
//  Copyright © 2018 Чайка. All rights reserved.
//

import Cocoa
import DeuxCheVaux

public struct Images {
	public let noImageUser: NSImage?
	public let anonymous: NSImage?
	public let offifical: NSImage?
	public let cruise: NSImage?
}// end struct Images

private let ThumbnailAPIFormat: String = "https://secure-dcdn.cdn.nimg.jp/nicoaccount/usericon/%@/%@.jpg"
private let NoImageThumbnailURL: String = "https://secure-dcdn.cdn.nimg.jp/nicoaccount/usericon/defaults/blank.jpg"
private let NicknameAPIFormat: String = "http://seiga.nicovideo.jp/api/user/info?id="
private let VitaAPIFormat: String = "http://api.ce.nicovideo.jp/api/v1/user.info?user_id="
private let NicknameNodeName: String = "nickname"

private let cruiseUserIdentifier: String = "394"
private let cruiseUserName: String = "Cruise"
private let informationUserIdentifier: String = "900000000"
private let informationUserName: String = "Information"

public final class NicoLiveListeners: NSObject {
	private var currentUsers: Dictionary<String, NicoLiveUser>
	private var knownUsers: NSMutableDictionary
	private var allKnownUsers: NSMutableDictionary
	private let ownerIdentifier: String
	private var observer: NSObject?
	
	private var images: Images!
	private let cookies: Array<HTTPCookie>
	private let session: URLSession = URLSession(configuration: URLSessionConfiguration.default)
	private var reqest: URLRequest
	
	public init (owner: String, for listeners: NSMutableDictionary, and allKnownUsers: NSMutableDictionary, user_session: [HTTPCookie], observer: NSObject? = nil) {
		ownerIdentifier = owner
		currentUsers = Dictionary()
		knownUsers = listeners
		cookies = user_session
		self.allKnownUsers = allKnownUsers
		self.observer = observer
		reqest = URLRequest(url: URL(string: NicknameAPIFormat)!)
		reqest.allHTTPHeaderFields = HTTPCookie.requestHeaderFields(with: cookies)
	}// end init
	
	public func setDefaultThumbnails(images: Images) {
		self.images = images
	}// end setDefaultThumbnails

	public func user (identifier: String) throws -> NicoLiveUser {
		if let user: NicoLiveUser = currentUsers[identifier] { return user}
		else { throw UserslistError.notInListeners }
	}// end user
	
	public func user (identifier: String, premium: Int) throws -> NicoLiveUser {
		if let user:NicoLiveUser = currentUsers[identifier] {
			parse(user: user, id: identifier, premium: premium)
			return user
		} else {
			if let _ = knownUsers[identifier] { throw UserslistError.entriedUser }
			else if let _ = allKnownUsers[identifier] {throw UserslistError.inDatabaseUser }
			else { throw UserslistError.unknownUser }
		}// end if current user is in current users dictionary
	}// end func user
	
	public func activateUser (identifier: String, premium: Int, anonymous: Bool, lang: UserLanguage) throws -> NicoLiveUser {
		guard let entry: NSMutableDictionary = knownUsers[identifier] as? NSMutableDictionary else { throw UserslistError.canNotActivateUser }
		var nickname: String = ""
		if !anonymous { nickname = fetchNickname(identifier: identifier) }
		else if premium == 0x11 { nickname = fetchNickname(identifier: ownerIdentifier) }
		else if identifier == cruiseUserIdentifier { nickname = cruiseUserName }
		else if identifier == informationUserIdentifier { nickname = informationUserName }
		
		var user: NicoLiveUser
		if premium ^ 0x011 == 0 {
			user = NicoLiveUser(user: entry, nickname: nickname, identifier: identifier, premium: premium, anonymous: anonymous, lang: lang)
		} else {
			user = NicoLiveUser(user: entry, nickname: nickname, identifier: identifier, premium: premium, anonymous: anonymous, lang: lang)
		}// end if premium flags is owner
		parse(user: user, id: identifier, premium: premium)

		fetchThumbnail(user: user, identifier: identifier, anonymous: anonymous)
		currentUsers[identifier] = user
		allKnownUsers[identifier] = anonymous
		
		return user
	}// end func activateUser
	
	public func newUser (identifier: String, premium: Int, anonymous: Bool, lang: UserLanguage, met: Friendship) -> NicoLiveUser {
		var nickname: String = ""
		if !anonymous { nickname = fetchNickname(fromVitaAPI: identifier) }
		else if premium == 0x11 { nickname = fetchNickname(fromVitaAPI: ownerIdentifier) }
		else if identifier == informationUserIdentifier { nickname = informationUserName }
		
		let user: NicoLiveUser = NicoLiveUser(nickname: nickname, identifier: identifier, premium: premium, anonymous: anonymous, lang: lang, met: met)
		parse(user: user, id: identifier, premium: premium)
		fetchThumbnail(user: user, identifier: identifier, anonymous: anonymous)
		currentUsers[identifier] = user
		allKnownUsers[identifier] = anonymous
		knownUsers[identifier] = user.entry
		
		return user
	}// end func newUser

	private func parse (user usr: NicoLiveUser, id identifier: String, premium prem: Int) {
		if (identifier == informationUserIdentifier) {
			usr.privilege = Privilege.official
			usr.name.nickname = "Information"
		}
		else if (prem & 0b110) == 0b110 { usr.privilege = Privilege.official }
		else if (prem & (0x01 << 1)) != 0x00 { usr.privilege = Privilege.owner }
		else if (prem & 0b11) == 0b11 { usr.privilege = Privilege.cruise }
	}// end parse
	
	private func fetchNickname (identifier: String) -> String {
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
				}// end try - catch parse XML document
			}// end if data is there
			fetchData = true
		}// end closure for recieve data
		task.resume()
		
		while (!fetchData) { Thread.sleep(forTimeInterval: 0.001)}
		return nickname
	}// end func fetchNickname
	
	private func fetchNickname(fromVitaAPI identifier: String) -> String {
		guard let url = URL(string: VitaAPIFormat + identifier) else { return "" }
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
					Swift.print(identifier)
					Swift.print(String(data: data, encoding: .utf8)!)
				}// end try - catch parse XML document
			}// end if data is there
			fetchData = true
		}// end closure for recieve data
		task.resume()
		
		while (!fetchData) { Thread.sleep(forTimeInterval: 0.001)}
		return nickname
	}// end fetchNickname fromVitaAPI
	
	private func fetchThumbnail (user: NicoLiveUser, identifier: String, anonymous: Bool) {
		if identifier == cruiseUserIdentifier {
			user.thumbnail = self.images.cruise
		} else if identifier == informationUserIdentifier {
			user.thumbnail = self.images.offifical
		} else if anonymous {
			user.thumbnail = self.images.anonymous
		} else {
			let thumbURL: URL = thumbnailURL(identifier: identifier)
			if let observer = observer {
				user.addObserver(observer, forKeyPath: "thumbnail", options: [], context: nil)
			}// end if need observe thumbnail
			
			reqest.url = thumbURL
			let task: URLSessionDataTask = session.dataTask(with: reqest) { (dat, resp, err) in
				if let data = dat, let image: NSImage = NSImage(data: data) {
					user.thumbnail = image
				} else {
					user.thumbnail = self.images.noImageUser
				}// end if data is valid
			}// end closure when recieve data
			task.resume()
		}// end !anonymous
	}// end fetchThumbnail
	
	private func thumbnailURL(identifier: String) -> URL {
		let prefix: String = String(identifier.prefix(identifier.count - 4))
		let urlString: String = String(format: ThumbnailAPIFormat, prefix, identifier)
		let url: URL = URL(string: urlString) ?? URL(string: NoImageThumbnailURL)!
		
		return url
	}// end func thumbnailURL
}// end class NicoLiveListeners
