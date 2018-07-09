//
//  NicoLiveListeners.swift
//  UserslistDB
//
//  Created by Чайка on 2018/07/05.
//  Copyright © 2018 Чайка. All rights reserved.
//

import Cocoa
import DeuxCheVaux

class NicoLiveListeners: NSObject {
	private var currentUsers: Dictionary<String, NicoLiveUser>
	private var knownUsers: NSMutableDictionary
	private var allKnownUsers: NSMutableDictionary

	init (listeners: NSMutableDictionary, allKnownUsers: NSMutableDictionary) {
		currentUsers = Dictionary()
		knownUsers = listeners
		self.allKnownUsers = allKnownUsers
	}// end init

	func user (identifier: String) throws -> NicoLiveUser {
		if let user:NicoLiveUser = currentUsers[identifier] {
			return user
		} else {
			if let _ = knownUsers[identifier] { throw UserslistError.entriedUser }
			else if let _ = allKnownUsers[identifier] {throw UserslistError.inDatabaseUser }
			else { throw UserslistError.unknownUser }
		}// end if current user is in current users dictionary
	}// end func user

	func activateUser (identifier: String, premium: Bool, anonymous: Bool, lang: UserLanguage) throws -> NicoLiveUser {
		guard let entry: NSMutableDictionary = knownUsers[identifier] as? NSMutableDictionary else { throw UserslistError.canNotActivateUser }
		let user: NicoLiveUser = NicoLiveUser(user: entry, identifier: identifier, premium: premium, anonymous: anonymous, lang: lang)
		currentUsers[identifier] = user
		allKnownUsers[identifier] = anonymous

		return user
	}// end func activateUser

	func newUser (nickname:String, identifier:String, premium:Bool, anonymous:Bool, lang:UserLanguage, met: Friendship) -> NicoLiveUser {
		let user: NicoLiveUser = NicoLiveUser(nickname: nickname, identifier: identifier, premium: premium, anonymous: anonymous, lang: lang, met: met)
		currentUsers[identifier] = user
		allKnownUsers[identifier] = anonymous

		return user
	}// end func newUser
}// end class NicoLiveListeners
