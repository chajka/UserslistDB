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

public typealias thumbNailCompletionhandler = ( (NicoLiveUser) -> Void )

private let cruiseUserIdentifier: String = "394"
private let cruiseUserName: String = "Cruise"
private let informationUserIdentifier: String = "900000000"
private let informationUserName: String = "Information"

fileprivate let UnknownName: String = "No Nickname (Charleston)"

internal let Owner: String = "BroadcastOwner"

public final class NicoLiveListeners: NSObject {
		// MARK: - Properties
	private(set) var owner: NicoLiveUser!
		// MARK: - Member variables
	private unowned var knownUsers: JSONizableUsers
	private var currentUsers: Dictionary<String, NicoLiveUser>
	private let ownerIdentifier: String

	private var images: Images!
	private weak var fetcher: NicoInformationHandler?

		// MARK: - Constructor/Destructor
	public init (owner: String, for listeners: JSONizableUsers, fetcher informationFetcher: NicoInformationHandler?) {
		ownerIdentifier = owner
		currentUsers = Dictionary()
		knownUsers = listeners
		fetcher = informationFetcher
		super.init()
		var ownersNickname: String
		if let fetcher: NicoInformationHandler = fetcher {
			ownersNickname = fetcher.fetchNickName(forIdentifier: owner) ?? UnknownName
		} else {
			ownersNickname = UnknownName
		}
		let ownerEntry = knownUsers.user(identifier: Owner, userName: ownersNickname).user
		self.owner = NicoLiveUser(owner: Owner, ownerEntry: ownerEntry, nickname: ownersNickname)
	}// end init

		// MARK: - Override
		// MARK: - Public methods
	public func finishProcess () {
		for user: NicoLiveUser in currentUsers.values {
			if user.entry.known == nil { user.entry.known = false }
		}// end foreach currentUsers
	}// end finishProcess

	public func setDefaultThumbnails(images: Images) {
		self.images = images
		self.owner.thumbnail = fetcher?.thumbnail(identifieer: ownerIdentifier, whenNoImage: images.noImageUser!)
	}// end setDefaultThumbnails

	public func user (identifier: String) throws -> NicoLiveUser {
		guard let user: NicoLiveUser = currentUsers[identifier] else { throw UserslistError.inactiveListener }

		return user
	}// end user

	public func activateUser (identifier: String, premium: Int, anonymous: Bool, lang: UserLanguage) -> NicoLiveUser {
		var nickname: String = ""
		if !anonymous || premium == 0b11 {
			nickname = fetcher?.fetchNickName(forIdentifier: identifier) ?? UnknownName
		} else if identifier == cruiseUserIdentifier { nickname = cruiseUserName }
		else if identifier == informationUserIdentifier { nickname = informationUserName }

		let userForIdentifier: (user: JSONizableUser, known: Bool) = knownUsers.user(identifier: identifier)
		let user: NicoLiveUser = NicoLiveUser(user: userForIdentifier.user, known: userForIdentifier.known, identifier: identifier, nickname: nickname, premium: premium, anonymous: anonymous, lang: lang)
		parse(user: user, id: identifier, premium: premium)

		if identifier == cruiseUserIdentifier {
			user.thumbnail = self.images.cruise
		} else if identifier == informationUserIdentifier {
			user.thumbnail = self.images.offifical
		} else if anonymous {
			user.thumbnail = self.images.anonymous
		} else {
			if let observer = observer {
				user.addObserver(observer, forKeyPath: "thumbnail", options: [], context: nil)
			}// end if need observe thumbnail
			user.thumbnail = fetcher?.thumbnail(identifieer: identifier, whenNoImage: self.images.noImageUser!)
		}
		currentUsers[identifier] = user

		return user
	}// end func activateUser

	public func set (commentAAnonymity anonymity: Bool) {
		knownUsers.anonymousComment = anonymity
	}// end set comment aonymity

		// MARK: - Internal methods
		// MARK: - Private methods
	private func parse (user usr: NicoLiveUser, id identifier: String, premium prem: Int) {
		if (identifier == informationUserIdentifier) {
			usr.privilege = Privilege.official
			usr.name.nickname = "Information"
			usr.name.handle = "Information"
		}
		else if (prem & 0b110) == 0b110 { usr.privilege = Privilege.official }
		else if (prem & (0x01 << 1)) != 0x00 { usr.privilege = Privilege.owner }
		else if (prem & 0b11) == 0b11 { usr.privilege = Privilege.cruise }
	}// end parse

		// MARK: - Delegates
}// end class NicoLiveListeners
